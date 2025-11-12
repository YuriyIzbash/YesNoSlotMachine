// SlotMachineView.swift
// Shared SwiftUI view for iOS and watchOS

import SwiftUI

struct SlotMachineView: View {
    @StateObject private var model = SlotMachineViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                gridView
                spinButton
            }
            .padding()

            if model.showResultOverlay, let resultIsYes = model.resultIsYes {
                resultOverlay(isYes: resultIsYes)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.25), value: model.showResultOverlay)
    }

    private var gridView: some View {
        VStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { r in
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { c in
                        let item = model.grid.indices.contains(r) && model.grid[r].indices.contains(c) ? model.grid[r][c] : SlotItem(imageName: "", isYes: false)
                        Image(item.imageName.isEmpty ? placeholderName(for: r, c) : item.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 80, maxHeight: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary.opacity(0.3)))
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
                .padding()
                .background(model.isSpinning ? Color.gray.opacity(0.4) : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(model.isSpinning)
    }

    @ViewBuilder
    private func resultOverlay(isYes: Bool) -> some View {
        let overlayText = isYes ? "Yes" : "No"
        let overlayColor: Color = isYes ? .green : .red

        VStack(spacing: 12) {
            Image(isYes ? (model.yesImageNames.first ?? "yes1") : (model.noImageNames.first ?? "no1"))
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            Text(overlayText)
                .font(.largeTitle.weight(.bold))
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(overlayColor.opacity(0.6), lineWidth: 3)
        )
        .shadow(radius: 10)
    }
}

#Preview {
    SlotMachineView()
}
