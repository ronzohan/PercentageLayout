import SwiftUI

/// A HStack that assigns its subviews width by percent provided accordingly
///
/// 1. If subviews count is only 1 but no width percentage defined, subview should fill the whole width
///    If subviews count is only 1 with width percentage defined, subview should fill accordingly to the
///    width percentage specified and leaving space behind for the remaining percentage.
/// 2. If subviews count is more than 1 but no specified width percentage, divide evenly to all item
/// 3. If subviews count is more than 1 but not all subviews has specified width percentage, subtract the
///    specified width percentage to the total and then divide evenly the remaining space to the unspecified
///    width percentage subviews
/// 4. If subviews count is more than 1 with all have specified width percentage, assign width percentage
///    to each subview accordingly
///
/// The following example shows a PercentageHStackLayout usage
///
///     var body: some View {
///         PercentageHStackLayout(
///             spacing: 10
///         ) {
///             Text("Subview 1")
///                 .widthPercent(0.1)
///
///             Text("Subview 2")
///                 .widthPercent(0.2)
///
///             Text("Subview 3")
///         }
///     }
///
/// >If the `widthPercent` is assigned to a value greater than 1, it will be assumed to  fill
/// the space remaining
public struct PercentageHStack: Layout {
    let spacing: CGFloat

    public init(spacing: CGFloat = 10) {
        self.spacing = spacing
    }

    private func currentSize(of subview: LayoutSubview,
                             in subviews: LayoutSubviews,
                             proposal: ProposedViewSize) -> CGSize {
        let proposalWithDimensions = proposal.replacingUnspecifiedDimensions()

        let widthPercent = widthPercent(of: subview, in: subviews)
        let totalSpacing = spacing * CGFloat(subviews.count - 1)
        let width = (proposalWithDimensions.width - totalSpacing) * widthPercent
        let newProposal = ProposedViewSize(width: width,
                                           height: nil)
        let size = subview.sizeThatFits(newProposal)
        return CGSize(width: width, height: size.height)
    }

    private func widthPercent(of subview: LayoutSubview, in subviews: LayoutSubviews) -> CGFloat {
        // Return the assigned width percentage if it has a defined value (e.g. values less than 1)
        if subview[WidthPercentage.self] < 1 {
            return subview[WidthPercentage.self]
        }

        // If the subview has no width percentage assigned,
        // get it by calculating the remaining space available
        // divided evenly with other subview which has no percentage assigned
        let subviewsWithPercentage = subviews
            .filter { min($0[WidthPercentage.self], 1) != 1 }

        let totalSpecifiedWidth = subviewsWithPercentage
            .reduce(0) { $0 + min($1[WidthPercentage.self], 1) }

        let totalWidth = (1 - totalSpecifiedWidth) / CGFloat(subviews.count - subviewsWithPercentage.count)
        return totalWidth
    }

    public func placeSubviews(in bounds: CGRect,
                              proposal: ProposedViewSize,
                              subviews: Subviews,
                              cache: inout ()) {
        var pt = CGPoint(x: bounds.minX, y: bounds.minY)

        for subview in subviews {
            let size = currentSize(of: subview, in: subviews, proposal: proposal)
            subview.place(at: pt, proposal: ProposedViewSize(size))

            pt.x += size.width + spacing
        }
    }

    public func sizeThatFits(proposal: ProposedViewSize,
                             subviews: Subviews,
                             cache: inout ()) -> CGSize {
        let viewSizes = subviews.map { currentSize(of: $0, in: subviews, proposal: proposal) }
        let defaultWidth: CGFloat = 10

        // Get the max height based on the calculated sizes
        let maxHeight = viewSizes.reduce(0) { currentMax, subviewSize in
            return max(currentMax, subviewSize.height)
        }

        return CGSize(width: proposal.width ?? defaultWidth, height: maxHeight)
    }
}

private struct WidthPercentage: LayoutValueKey {
    static var defaultValue: CGFloat = 1
}

extension View {
    public func widthPercent(_ value: CGFloat) -> some View {
        layoutValue(key: WidthPercentage.self, value: value)
    }
}
