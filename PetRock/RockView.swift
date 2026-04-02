import SwiftUI

struct RockView: View {
    @State private var message = ""
    @State private var showMessage = false
    @State private var clickCount = 0
    @State private var wobble = false
    @State private var idleText = ""
    @State private var showIdle = false
    @State private var idleEnabled = false
    @State private var mouseLocation = CGPoint.zero
    @State private var idleTimer: Timer?

    private let rejections = [
        "no.", "no", "nope", "nah", "absolutely not", "hard pass",
        "denied", "lol no", "nein", "non", "いいえ", "niet",
        "why", "stop", "don't", "leave me alone", "i'm a rock",
        "go away", "no thanks", "pass", "negative", "nuh uh",
        "not happening", "try again never", "rocks don't do that",
        "i literally cannot", "that's not my job", "i have no hands",
        "read the job description", "i'm on break", "did i stutter",
        "🪨", "...", "bruh", "respectfully, no", "unsubscribe",
        "per my last no", "as per my previous rejection",
        "i don't have the bandwidth", "let me circle back to no"
    ]

    private let idleThoughts = [
        "...", "*exists*", "*sits*", "*does nothing*", "*is rock*",
        "*vibes*", "*mineral noises*", "zz", "*geological patience*",
        "*contemplates entropy*", "*igneous stillness*"
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.91, green: 0.86, blue: 0.78),
                    Color(red: 0.55, green: 0.62, blue: 0.46)
                ],
                startPoint: .top, endPoint: .bottom
            )

            VStack(spacing: 0) {
                // Header with toggle
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PET ROCK")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .tracking(4)
                            .foregroundColor(.brown.opacity(0.6))
                        Text("it does nothing")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.brown.opacity(0.4))
                    }
                    Spacer()
                    Button(action: {
                        idleEnabled.toggle()
                        if !idleEnabled {
                            showIdle = false
                            idleText = ""
                        }
                    }) {
                        Image(systemName: idleEnabled ? "thought.bubble.fill" : "thought.bubble")
                            .font(.system(size: 13))
                            .foregroundColor(.brown.opacity(idleEnabled ? 0.6 : 0.3))
                    }
                    .buttonStyle(.plain)
                    .help(idleEnabled ? "Disable thoughts" : "Enable thoughts")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                // Idle thought
                Text(showIdle && idleEnabled ? idleText : " ")
                    .font(.system(size: 11, design: .monospaced))
                    .italic()
                    .foregroundColor(.brown.opacity(0.5))
                    .animation(.easeInOut(duration: 0.5), value: showIdle)
                    .frame(height: 16)

                // Speech bubble
                ZStack {
                    if showMessage {
                        VStack(spacing: 0) {
                            Text(message)
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.white)
                                        .shadow(radius: 4, y: 2)
                                )
                            Triangle()
                                .fill(.white)
                                .frame(width: 14, height: 8)
                        }
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
                .frame(height: 50)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showMessage)

                // The Rock
                ZStack {
                    RockShape()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.58, blue: 0.56),
                                    Color(red: 0.49, green: 0.47, blue: 0.45),
                                    Color(red: 0.35, green: 0.33, blue: 0.31)
                                ],
                                center: UnitPoint(x: 0.4, y: 0.35),
                                startRadius: 0, endRadius: 100
                            )
                        )
                        .frame(width: 160, height: 130)
                        .shadow(color: .black.opacity(0.3), radius: 12, y: 10)

                    HStack(spacing: 18) {
                        GooglyEyeView(eyeSize: 22, mouseLocation: mouseLocation)
                        GooglyEyeView(eyeSize: 24, mouseLocation: mouseLocation)
                    }
                    .offset(y: -8)
                }
                .rotationEffect(.degrees(wobble ? Double.random(in: -4...4) : 0))
                .scaleEffect(wobble ? 0.95 : 1.0)
                .animation(.spring(response: 0.15, dampingFraction: 0.3), value: wobble)
                .onTapGesture { handleClick() }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let loc): mouseLocation = loc
                    case .ended: break
                    }
                }

                Spacer()

                // Stats
                VStack(spacing: 3) {
                    Text("times bothered: \(clickCount)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.brown.opacity(0.5))
                    Text("features: none · updates: never")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.brown.opacity(0.35))
                }
                .padding(.bottom, 14)
            }
        }
        .frame(width: 280, height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear { startIdleTimer() }
        .onDisappear { idleTimer?.invalidate() }
    }

    private func handleClick() {
        clickCount += 1
        message = rejections.randomElement() ?? "no"
        showMessage = true
        wobble = true
        showIdle = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { wobble = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { showMessage = false }
    }

    private func startIdleTimer() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            guard idleEnabled, !showMessage else { return }
            idleText = idleThoughts.randomElement() ?? ""
            showIdle = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { showIdle = false }
        }
    }
}

// MARK: - Shapes

struct RockShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.75))
        path.addQuadCurve(to: CGPoint(x: w * 0.12, y: h * 0.42),
                          control: CGPoint(x: w * 0.05, y: h * 0.58))
        path.addQuadCurve(to: CGPoint(x: w * 0.25, y: h * 0.22),
                          control: CGPoint(x: w * 0.15, y: h * 0.30))
        path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.12),
                          control: CGPoint(x: w * 0.35, y: h * 0.12))
        path.addQuadCurve(to: CGPoint(x: w * 0.78, y: h * 0.18),
                          control: CGPoint(x: w * 0.65, y: h * 0.10))
        path.addQuadCurve(to: CGPoint(x: w * 0.92, y: h * 0.42),
                          control: CGPoint(x: w * 0.88, y: h * 0.25))
        path.addQuadCurve(to: CGPoint(x: w * 0.88, y: h * 0.72),
                          control: CGPoint(x: w * 0.96, y: h * 0.55))
        path.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.88),
                          control: CGPoint(x: w * 0.85, y: h * 0.82))
        path.addQuadCurve(to: CGPoint(x: w * 0.40, y: h * 0.90),
                          control: CGPoint(x: w * 0.55, y: h * 0.92))
        path.addQuadCurve(to: CGPoint(x: w * 0.15, y: h * 0.75),
                          control: CGPoint(x: w * 0.25, y: h * 0.88))
        path.closeSubpath()
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.midX + rect.width / 2, y: 0))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    RockView()
}
