import SwiftUI

/// Wiederverwendbare, elegante Info- und Empfehlungskarte für Einsteiger
public struct ExpertTipsCardView: View {
    public let tab: NavigationTab
    public let accentColor: Color
    public let cornerRadius: CGFloat
    
    @State private var isExpanded: Bool = true
    
    public init(tab: NavigationTab, accentColor: Color, cornerRadius: CGFloat = 16) {
        self.tab = tab
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
    }
    
    private var recommendation: TabRecommendation {
        TabRecommendationsDatabase.recommendation(for: tab)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Clickable to toggle collapse/expand
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(alignment: .center, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(accentColor.opacity(0.18))
                            .frame(width: 32, height: 32)
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("💡 Experten-Tipps für Einsteiger")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("\(recommendation.tips.count) Empfehlungen")
                                .font(.system(size: 10, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(accentColor.opacity(0.12))
                                .foregroundColor(accentColor)
                                .clipShape(Capsule())
                        }
                        
                        Text(recommendation.summary)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(isExpanded ? 3 : 1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(Color(PlatformColor.secondarySystemBackground).opacity(0.8))
                        .clipShape(Circle())
                }
            }
            .buttonStyle(.plain)
            
            // Expanded List of Expert Tips
            if isExpanded {
                Divider()
                    .padding(.vertical, 2)
                
                VStack(spacing: 10) {
                    ForEach(recommendation.tips) { tip in
                        tipRow(tip)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(PlatformColor.secondarySystemBackground).opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func tipRow(_ tip: ExpertTip) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(tip.badgeType.badgeColor.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Image(systemName: tip.systemIcon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(tip.badgeType.badgeColor)
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(tip.headline)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(tip.badgeType.rawValue)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(tip.badgeType.badgeColor.opacity(0.15))
                        .foregroundColor(tip.badgeType.badgeColor)
                        .clipShape(Capsule())
                }
                
                Text(tip.text)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(PlatformColor.systemBackground).opacity(0.6))
        )
    }
}
