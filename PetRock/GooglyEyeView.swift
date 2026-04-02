import SwiftUI

struct GooglyEyeView: View {
    let eyeSize: CGFloat
    let mouseLocation: CGPoint
    @State private var pupilOffset = CGSize.zero

    var body: some View {
        ZStack {
            // White of eye
            Ellipse()
                .fill(.white)
                .stroke(Color(white: 0.2), lineWidth: 1.5)
                .frame(width: eyeSize * 2, height: eyeSize * 2.1)

            // Pupil
            Circle()
                .fill(Color(white: 0.07))
                .frame(width: eyeSize * 0.95, height: eyeSize * 0.95)
                .offset(pupilOffset)
                .onChange(of: mouseLocation) { _, newPos in
                    let dx = newPos.x - 140
                    let dy = newPos.y - 200
                    let dist = sqrt(dx * dx + dy * dy)
                    let maxOff = eyeSize * 0.4
                    let norm = min(dist / 100, 1.0)
                    if dist > 1 {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            pupilOffset = CGSize(
                                width: (dx / dist) * maxOff * norm,
                                height: (dy / dist) * maxOff * norm
                            )
                        }
                    }
                }

            // Glint
            Circle()
                .fill(.white.opacity(0.8))
                .frame(width: eyeSize * 0.25, height: eyeSize * 0.25)
                .offset(
                    x: pupilOffset.width + eyeSize * 0.15,
                    y: pupilOffset.height - eyeSize * 0.15
                )
        }
    }
}
