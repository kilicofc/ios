import SwiftUI

struct ExerciseView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let ex: Exercise

    enum Stage { case run, rate, result }
    @State private var stage: Stage = .run
    @State private var message = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(ex.title).font(.title2.bold())
                Text(ex.desc).foregroundStyle(.secondary)
                switch stage {
                case .run: runBody
                case .rate: rateBody
                case .result: resultBody
                }
            }
            .padding()
        }
        .navigationTitle("Seviye \(ex.level) · \(ex.id)")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private var runBody: some View {
        switch ex.kind {
        case .breath:
            BreathView(ex: ex, onFinish: { stage = .rate })
        case .steps:
            StepsView(ex: ex, onFinish: { stage = .rate })
            RecorderBar()
        case .pace:
            PaceView(ex: ex, onFinish: { stage = .rate })
            RecorderBar()
        }
    }

    @ViewBuilder private var rateBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nasıl geçti?").font(.headline)
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { i in
                    Button {
                        message = store.record(ex, rating: i + 1)
                        stage = .result
                    } label: {
                        VStack(spacing: 2) {
                            Text("\(i + 1)").font(.title2.bold())
                            Text(Content.rateLabels[i]).font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                }
            }
            Text("3 ve üstü: çalışma tamam sayılır. 1-2: planına tekrar olarak eklenir.")
                .font(.footnote).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var resultBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kaydedildi").font(.headline)
            Text(message)
            Button("Bugünkü derse dön") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: Nefes

struct BreathView: View {
    let ex: Exercise
    let onFinish: () -> Void

    @State private var running = false
    @State private var started = false
    @State private var finished = false
    @State private var phaseIdx = 0
    @State private var remaining = 0
    @State private var cycle = 0
    @State private var scale: CGFloat = 0.5
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var phases: [(String, Int, CGFloat)] {
        let p = ex.pattern
        let all: [(String, Int, CGFloat)] = [
            ("Nefes al", p[0], 1.0),
            ("Tut", p[1], 1.0),
            ("Yavaşça ver", p[2], 0.5),
            ("Bekle", p[3], 0.5)
        ]
        return all.filter { $0.1 > 0 }
    }

    private var label: String {
        if finished { return "Bitti" }
        if !started { return "Hazır" }
        return phases[min(phaseIdx, phases.count - 1)].0
    }

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.tane.opacity(0.85))
                    .scaleEffect(scale)
                VStack(spacing: 2) {
                    Text(label).font(.headline).foregroundStyle(.white)
                    if started && !finished {
                        Text("\(remaining)").font(.system(size: 40, weight: .medium, design: .monospaced)).foregroundStyle(.white)
                    }
                }
            }
            .frame(width: 260, height: 260)
            Text("\(cycle) / \(ex.cycles)").font(.caption).foregroundStyle(.secondary)
            HStack {
                Button(finished ? "Devam et" : (running ? "Duraklat" : (started ? "Devam" : "Başla"))) {
                    if finished { onFinish(); return }
                    if !started { started = true; enter() }
                    running.toggle()
                }
                .buttonStyle(.borderedProminent)
                Button("Bitir") { running = false; onFinish() }
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .onReceive(timer) { _ in tick() }
    }

    private func enter() {
        let p = phases[phaseIdx]
        remaining = p.1
        withAnimation(.easeInOut(duration: Double(p.1))) { scale = p.2 }
    }

    private func tick() {
        guard running else { return }
        remaining -= 1
        if remaining > 0 { return }
        phaseIdx += 1
        if phaseIdx >= phases.count {
            phaseIdx = 0
            cycle += 1
            if cycle >= ex.cycles {
                running = false
                finished = true
                return
            }
        }
        enter()
    }
}

// MARK: Adım adım

struct StepsView: View {
    let ex: Exercise
    let onFinish: () -> Void

    @State private var i = 0
    @State private var left = 0
    @State private var running = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private func fmt(_ s: Int) -> String { "\(s / 60):" + String(format: "%02d", s % 60) }

    var body: some View {
        let s = ex.steps[i]
        let last = i == ex.steps.count - 1
        VStack(alignment: .leading, spacing: 14) {
            Text("ADIM \(i + 1) / \(ex.steps.count)")
                .font(.caption.monospaced()).foregroundStyle(.secondary)
            Text(s.title).font(.title3.bold())
            Text(s.text)
            if let q = s.quote {
                Text(q)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.tane.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            }
            if let secs = s.secs {
                VStack(spacing: 10) {
                    Text(fmt(left)).font(.system(size: 44, weight: .medium, design: .monospaced))
                    Button(left == 0 ? "Süre doldu" : (running ? "Duraklat" : (left == secs ? "Süreyi başlat" : "Devam"))) {
                        running.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(left == 0)
                }
                .frame(maxWidth: .infinity)
            }
            HStack {
                Button("Geri") { i -= 1; reset() }
                    .buttonStyle(.bordered)
                    .disabled(i == 0)
                Button(last ? "Bitir" : "Sonraki") {
                    if last { onFinish() } else { i += 1; reset() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear { reset() }
        .onReceive(timer) { _ in
            guard running else { return }
            if left > 0 { left -= 1 }
            if left == 0 { running = false }
        }
    }

    private func reset() {
        running = false
        left = ex.steps[i].secs ?? 0
    }
}

// MARK: Hız ayarlı okuma

@MainActor
final class PaceEngine: ObservableObject {
    @Published var index = -1
    @Published var running = false
    var tokens: [String] = []
    var wpm: Double = 100
    private var task: Task<Void, Never>?

    func load(_ line: String) {
        stop()
        tokens = line.split(whereSeparator: { $0 == " " || $0 == "\n" }).map { String($0) }
        index = -1
    }

    func isPause(_ t: String) -> Bool { !t.isEmpty && t.allSatisfy { $0 == "|" } }

    private func syllables(_ w: String) -> Int {
        let v = Set("aeıioöuüâîû")
        let n = w.lowercased().filter { v.contains($0) }.count
        return max(1, n)
    }

    private func duration(_ t: String) -> Double {
        let unit = 60000.0 / wpm
        if isPause(t) { return Double(t.count) * unit * 0.7 }
        let f = min(2.5, max(0.5, Double(syllables(t)) / 2.8))
        return unit * f
    }

    func toggle() { running ? stop() : play() }

    func play() {
        stop()
        if index >= tokens.count - 1 { index = -1 }
        running = true
        task = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { return }
                self.index += 1
                if self.index >= self.tokens.count {
                    self.running = false
                    return
                }
                let ms = self.duration(self.tokens[self.index])
                try? await Task.sleep(nanoseconds: UInt64(ms * 1_000_000))
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        running = false
    }
}

struct PaceView: View {
    @EnvironmentObject var store: Store
    let ex: Exercise
    let onFinish: () -> Void

    @StateObject private var engine = PaceEngine()
    @State private var line = 0
    @State private var wpm: Double = 100
    @State private var streakCount = 0
    @State private var hint = ""

    private func label(_ w: Double) -> String {
        w < 90 ? "yavaş" : (w < 130 ? "rahat" : (w < 160 ? "haber temposu" : "hızlı"))
    }

    private var lineText: Text {
        var t = Text("")
        for (k, tok) in engine.tokens.enumerated() {
            if engine.isPause(tok) {
                t = t + Text("· ").foregroundColor(.secondary)
            } else if k == engine.index {
                t = t + Text(tok + " ").foregroundColor(Color.tane).bold()
            } else {
                t = t + Text(tok + " ")
            }
        }
        return t
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SATIR \(line + 1) / \(ex.lines.count)")
                .font(.caption.monospaced()).foregroundStyle(.secondary)
            lineText
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)

            Button(engine.running ? "Duraklat" : "Başlat") { engine.toggle() }
                .buttonStyle(.borderedProminent)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(Int(wpm)) kelime/dk").bold()
                    Text(label(wpm)).foregroundStyle(.secondary)
                }
                Slider(value: $wpm, in: 50...220, step: 5) { editing in
                    engine.wpm = wpm
                    if !editing { store.s.wpm[ex.id] = Int(wpm) }
                }
                .onChange(of: wpm) { v in engine.wpm = v }
            }

            HStack {
                Button("Temiz söyledim") { streakCount += 1; hint = "" }
                    .buttonStyle(.bordered)
                Button("Takıldım") {
                    streakCount = 0
                    hint = "Takılmak normal. Hız yerine kontrolü çalış: yavaşla ve her sesi tane tane söyle."
                }
                .buttonStyle(.bordered)
            }

            if streakCount >= 3 {
                HStack {
                    Text("3 temiz tekrar. Hızı %10 artırmaya hazırsın.").font(.subheadline)
                    Spacer()
                    Button("Hızı artır") {
                        let nv = min(220, (wpm * 1.1 / 5).rounded() * 5)
                        wpm = nv
                        engine.wpm = nv
                        store.s.wpm[ex.id] = Int(nv)
                        streakCount = 0
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(10)
                .background(Color.tane.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            } else if streakCount > 0 {
                Text("Temiz seri: \(streakCount) / 3").font(.footnote).foregroundStyle(.secondary)
            }
            if !hint.isEmpty {
                Text(hint).font(.footnote).foregroundStyle(.secondary)
            }

            HStack {
                Button("Önceki") { if line > 0 { line -= 1; engine.load(ex.lines[line]) } }
                    .buttonStyle(.bordered)
                Button("Sonraki satır") { if line < ex.lines.count - 1 { line += 1; engine.load(ex.lines[line]) } }
                    .buttonStyle(.bordered)
                Button("Bitir") {
                    engine.stop()
                    store.s.wpm[ex.id] = Int(wpm)
                    onFinish()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            wpm = Double(store.s.wpm[ex.id] ?? ex.wpm)
            engine.wpm = wpm
            engine.load(ex.lines[0])
        }
        .onDisappear { engine.stop() }
    }
}
