//
//  SlotMachineView_watch.swift
//  WatchYesNoSlotMachine Watch App
//
//  Created by yuriy on 11/13/25.
//

import SwiftUI

struct WatchSlotMachineView: View {
    @StateObject private var model = WatchSlotMachineViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                gridView
                spinButton
            }
            .padding(8)

            if model.showResultOverlay, let resultIsYes = model.resultIsYes {
                resultOverlay(isYes: resultIsYes)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.25), value: model.showResultOverlay)
    }

    private var gridView: some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { r in
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { c in
                        let item = model.grid.indices.contains(r) && model.grid[r].indices.contains(c) ? model.grid[r][c] : WatchSlotItem(imageName: "", isYes: false)
                        Image(item.imageName.isEmpty ? placeholderName(for: r, c) : item.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 40, maxHeight: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3)))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func placeholderName(for r: Int, _ c: Int) -> String {
        // Fallback while grid initializes
        return (r + c) % 2 == 0 ? (model.yesImageNames.first ?? "yes1") : (model.noImageNames.first ?? "no1")
    }

    private var spinButton: some View {
        Button(action: model.spin) {
            Text(model.isSpinning ? "Spinning…" : "Spin")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(model.isSpinning ? Color.gray.opacity(0.4) : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(model.isSpinning)
    }

    @ViewBuilder
    private func resultOverlay(isYes: Bool) -> some View {
        let overlayText = isYes ? "Yes" : "No"
        let overlayColor: Color = isYes ? .green : .red

        VStack(spacing: 8) {
            Image(isYes ? (model.yesImageNames.first ?? "yes1") : (model.noImageNames.first ?? "no1"))
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
            Text(overlayText)
                .font(.title2.weight(.bold))
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(overlayColor.opacity(0.6), lineWidth: 2)
        )
        .shadow(radius: 6)
    }
}

#Preview {
    WatchSlotMachineView()
}
