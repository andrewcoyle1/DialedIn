//
//  CarouselView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/7/24.
//

import SwiftUI

struct CarouselView<Content: View, T: Hashable>: View {
    
    var items: [T]
    var showsPageCounter: Bool = false
    var showsPageCounterOnlyWhileInteracting: Bool = true
    var height: CGFloat = 200
    @ViewBuilder var content: (T) -> Content
    @State private var selection: T?
    @State private var isInteracting: Bool = false
    @State private var counterHideWorkItem: DispatchWorkItem?
    var onSelectionChange: ((T?) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .scrollTransition(.interactive.threshold(.visible(0.95)), transition: { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                            })
                            .containerRelativeFrame(.horizontal, alignment: .center)
                            .id(item)
                    }
                }
            }
            .frame(minHeight: height)
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selection)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        showCounterAndScheduleHide()
                    }
                    .onEnded { _ in
                        showCounterAndScheduleHide()
                    }
            )
            .overlay(alignment: .topTrailing) {
                if shouldShowPageCounter {
                    Text("\(currentIndex + 1)/\(max(items.count, 1))")
                        .font(.caption2.weight(.semibold))
                        .monospacedDigit()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(8)
                        .transition(.opacity)
                }
            }
            .onChange(of: items.count, { _, _ in
                updateSelectionIfNeeded()
            })
            .onChange(of: selection) { _, newValue in
                onSelectionChange?(newValue)
            }
            .onAppear {
                updateSelectionIfNeeded()
                onSelectionChange?(selection)
            }
            slidingDotsIndicator()
        }
    }
    
    private var currentIndex: Int {
        guard let selection, let idx = items.firstIndex(of: selection) else { return 0 }
        return idx
    }

    private var shouldShowPageCounter: Bool {
        guard showsPageCounter, items.count > 0 else { return false }
        if showsPageCounterOnlyWhileInteracting {
            return isInteracting
        }
        return true
    }

    @ViewBuilder
    private func slidingDotsIndicator(maxVisible: Int = 5) -> some View {
        let total = items.count
        let visible = min(total, maxVisible)
        if visible > 0 {
            let idx = currentIndex
            let start = (total <= maxVisible)
                ? 0
                : min(max(0, idx - (maxVisible - 2)), total - maxVisible)
            let end = start + visible
            HStack(spacing: 8) {
                ForEach(start..<end, id: \.self) { iteration in
                    let hasHiddenLeft = start > 0
                    let hasHiddenRight = end < total
                    let isActive = iteration == idx
                    let isEdge = (iteration == start && hasHiddenLeft) || (iteration == end - 1 && hasHiddenRight)
                    let scale: CGFloat = (isActive ? 1.0 : (isEdge ? 0.7 : 1.0))
                    let edgeOpacity: Double = (isActive ? 1.0 : (isEdge ? 0.7 : 1.0))

                    Circle()
                        .fill(isActive ? .accent : .secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .scaleEffect(scale)
                        .opacity(edgeOpacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selection)
        } else {
            EmptyView()
        }
    }

    private func updateSelectionIfNeeded() {
        if selection == nil || selection == items.last {
            selection = items.first
        }
    }

    private func showCounterAndScheduleHide() {
        guard showsPageCounter else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            isInteracting = true
        }
        counterHideWorkItem?.cancel()
        let work = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.25)) {
                isInteracting = false
            }
        }
        counterHideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: work)
    }
}

#Preview {
    CarouselView(items: ExerciseTemplateModel.mocks) { item in
        HeroCellView(
            title: item.name,
            subtitle: item.description,
            imageName: item.imageURL
        )
    }
    .padding()
}
