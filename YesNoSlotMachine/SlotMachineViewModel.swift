// SlotMachineViewModel.swift
// Shared view model for iOS and watchOS slot machine

import Foundation
import Combine

struct SlotItem: Equatable {
    let imageName: String
    let isYes: Bool
}

final class SlotMachineViewModel: ObservableObject {
    // Configure your asset names here. Provide 6 images for Yes and 6 for No.
    // Example asset names: yes1...yes6 and no1...no6
    let yesImageNames: [String]
    let noImageNames: [String]

    @Published var grid: [[SlotItem]] = [] // 3x3
    @Published var isSpinning: Bool = false
    @Published var showResultOverlay: Bool = false
    @Published var resultIsYes: Bool? = nil

    private var spinTimer: Timer?

    init(
        yesImageNames: [String] = ["yes1","yes2","yes3","yes4","yes5","yes6"],
        noImageNames: [String] = ["no1","no2","no3","no4","no5","no6"]
    ) {
        self.yesImageNames = yesImageNames
        self.noImageNames = noImageNames
        resetGrid()
    }

    func resetGrid() {
        // Initialize with random items
        grid = (0..<3).map { _ in
            (0..<3).map { _ in randomItem() }
        }
        isSpinning = false
        showResultOverlay = false
        resultIsYes = nil
    }

    func spin() {
        guard !isSpinning else { return }
        isSpinning = true
        showResultOverlay = false
        resultIsYes = nil

        // Start a fast timer to update all cells while spinning
        spinTimer?.invalidate()
        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            for r in 0..<3 {
                for c in 0..<3 {
                    self.grid[r][c] = self.randomItem()
                }
            }
        }

        // Stop after a short duration and evaluate
        let stopAfter = 1.6 // seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) { [weak self] in
            self?.finishSpin()
        }
    }

    private func finishSpin() {
        spinTimer?.invalidate()
        spinTimer = nil
        isSpinning = false

        // Finalize grid values one last time for determinism
        for r in 0..<3 {
            for c in 0..<3 {
                grid[r][c] = randomItem()
            }
        }

        // Evaluate middle row (row index 1)
        let middleRow = grid[1]
        let yesCount = middleRow.filter { $0.isYes }.count
        // If more than 1 yes in the middle row -> Yes overlay; otherwise No overlay
        let resultYes = yesCount >= 2
        resultIsYes = resultYes
        showResultOverlay = true

        // Hide overlay after 3 seconds and get ready to spin again
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }
            self.showResultOverlay = false
            self.resultIsYes = nil
            // Grid stays as-is, spin can be triggered again
        }
    }

    private func randomItem() -> SlotItem {
        // 50/50 chance of yes/no; adjust if needed
        let isYes = Bool.random()
        if isYes {
            let name = yesImageNames.randomElement() ?? "yes1"
            return SlotItem(imageName: name, isYes: true)
        } else {
            let name = noImageNames.randomElement() ?? "no1"
            return SlotItem(imageName: name, isYes: false)
        }
    }
}
