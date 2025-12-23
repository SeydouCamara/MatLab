import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.cardCornerRadius)
                    .fill(Color.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cardCornerRadius)
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppConstants.UI.cardCornerRadius))
    }
}
