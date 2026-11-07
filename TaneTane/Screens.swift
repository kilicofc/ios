import SwiftUI

// MARK: Ortak satır

struct ExerciseRow: View {
    @EnvironmentObject var store: Store
    let e: Exercise

    var body: some View {
        HStack(spacing: 12) {
            statusIcon
            VStack(alignment: .leading, spacing: 2) {
                Text(e.title).font(.body.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var subtitle: String {
        let kind: String
        switch e.kind {
        case .breath: kind = "Nefes"
        case .pace: kind = "Okuma"
        case .steps: kind = "Adım adım"
        }
        var t = "\(kind) · \(e.minutes) dk"
        if let r = store.rating(e), r < 3 { t += " · tekrar" }
        return t
    }

    @ViewBuilder private var statusIcon: some View {
        if let r = store.rating(e) {
            if r >= 3 {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            } else {
                Image(systemName: "arrow.counterclockwise.circle").foregroundStyle(.orange)
            }
        } else {
            Image(systemName: "circle").foregroundStyle(.secondary)
        }
    }
}

// MARK: Bugün

struct HomeView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack {
            let plan = store.planToday()
            let doneCount = plan.filter { store.isDoneToday($0) }.count
            let mins = plan.reduce(0) { $0 + $1.minutes }
            let level = store.currentLevel
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(!plan.isEmpty && doneCount == plan.count
                             ? "Bugünlük tamam."
                             : "Seviye \(level): \(Content.levels[level - 1].title)")
                            .font(.title2.bold())
                        ProgressView(value: Double(doneCount), total: Double(max(plan.count, 1)))
                        Text("\(store.streak()) gün seri · yaklaşık \(mins) dk")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                Section("Bugünkü ders") {
                    ForEach(plan) { e in
                        NavigationLink {
                            ExerciseView(ex: e)
                        } label: {
                            ExerciseRow(e: e)
                        }
                    }
                }
                Section {
                    Text("Her gün 10-15 dakika, uzun ama düzensiz çalışmadan daha etkilidir. Bu uygulama eğitim amaçlıdır; süregelen konuşma sorunları için dil ve konuşma terapistine danış.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Tane Tane")
        }
    }
}

// MARK: Seviyeler

struct PathView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack {
            List {
                ForEach(Content.levels) { L in
                    let open = store.unlocked(L.n)
                    let items = store.exercises(in: L.n)
                    let ok = items.filter { (store.rating($0) ?? 0) >= 3 }.count
                    Section {
                        if open {
                            ForEach(items) { e in
                                NavigationLink {
                                    ExerciseView(ex: e)
                                } label: {
                                    ExerciseRow(e: e)
                                }
                            }
                        } else {
                            Label("Önceki seviyeyi tamamlayınca açılır.", systemImage: "lock")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("Seviye \(L.n) · \(L.title)  \(open ? "\(ok)/\(items.count)" : "kilitli")")
                    } footer: {
                        Text(L.sub)
                    }
                }
            }
            .navigationTitle("Seviyeler")
        }
    }
}

// MARK: İlerleme

struct MeView: View {
    @EnvironmentObject var store: Store
    @State private var confirmReset = false

    private var last14: [(String, Int, String)] {
        let cal = Calendar.current
        let names = ["Pz", "Pt", "Sa", "Ça", "Pe", "Cu", "Ct"]
        var out: [(String, Int, String)] = []
        for i in stride(from: 13, through: 0, by: -1) {
            let d = cal.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let k = store.dayKey(d)
            let wd = cal.component(.weekday, from: d) - 1
            out.append((k, store.s.days[k] ?? 0, names[max(0, min(6, wd))]))
        }
        return out
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Son 14 gün · dakika") {
                    let data = last14
                    let mx = Double(max(15, data.map { $0.1 }.max() ?? 15))
                    HStack(alignment: .bottom, spacing: 5) {
                        ForEach(data, id: \.0) { item in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.tane)
                                    .frame(height: max(2, CGFloat(Double(item.1) / mx) * 70))
                                Text(item.2).font(.system(size: 9)).foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 90, alignment: .bottom)
                    Text("\(store.streak()) gün seri · \(store.totalMinutes()) dk toplam")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                Section("Seviye ilerlemesi") {
                    ForEach(Content.levels) { L in
                        let items = store.exercises(in: L.n)
                        let ok = items.filter { (store.rating($0) ?? 0) >= 3 }.count
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Seviye \(L.n) · \(L.title)").font(.subheadline)
                                Spacer()
                                Text("\(ok)/\(items.count)").font(.caption).foregroundStyle(.secondary)
                            }
                            ProgressView(value: Double(ok), total: Double(items.count))
                        }
                    }
                }

                Section("Ayarlar") {
                    Picker("Günlük süre", selection: Binding(
                        get: { store.s.minutes },
                        set: { store.s.minutes = $0 }
                    )) {
                        ForEach([5, 10, 15, 20], id: \.self) { Text("\($0) dakika").tag($0) }
                    }
                    Picker("Başlangıç seviyesi", selection: Binding(
                        get: { store.s.startLevel },
                        set: { store.s.startLevel = $0 }
                    )) {
                        ForEach(1...4, id: \.self) { Text("Seviye \($0) ve öncesi açık").tag($0) }
                    }
                }

                Section("Zorlandığın sesler") {
                    ForEach(Content.weakOptions) { w in
                        Toggle(w.label, isOn: Binding(
                            get: { store.s.weak.contains(w.key) },
                            set: { on in
                                if on {
                                    if !store.s.weak.contains(w.key) { store.s.weak.append(w.key) }
                                } else {
                                    store.s.weak.removeAll { $0 == w.key }
                                }
                            }
                        ))
                    }
                }

                Section {
                    Button("İlerlemeyi sıfırla", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("İlerleme")
            .confirmationDialog("Tüm ilerleme silinecek.", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Evet, sıfırla", role: .destructive) { store.reset() }
                Button("Vazgeç", role: .cancel) {}
            }
        }
    }
}

// MARK: Karşılama

struct OnboardingView: View {
    @EnvironmentObject var store: Store
    @State private var minutes = 10
    @State private var weak: Set<String> = []
    @State private var level = 1

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Üç kısa soru. Sonradan İlerleme sekmesinden değiştirebilirsin.")
                        .foregroundStyle(.secondary)
                }
                Section("Hangi seslerde zorlanıyorsun?") {
                    ForEach(Content.weakOptions) { w in
                        Toggle(w.label, isOn: Binding(
                            get: { weak.contains(w.key) },
                            set: { on in
                                if on { weak.insert(w.key) } else { weak.remove(w.key) }
                            }
                        ))
                    }
                }
                Section("Günde ne kadar vakit ayırabilirsin?") {
                    Picker("Süre", selection: $minutes) {
                        ForEach([5, 10, 15, 20], id: \.self) { Text("\($0) dakika").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Başlangıç noktan") {
                    Picker("Seviye", selection: $level) {
                        Text("Sıfırdan başlıyorum").tag(1)
                        Text("Nefes ve duruşu biliyorum").tag(2)
                        Text("Isınmayı biliyorum, seslere geçeyim").tag(3)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section {
                    Button("Başlayalım") {
                        store.s.minutes = minutes
                        store.s.weak = Array(weak)
                        store.s.startLevel = level
                        store.s.onboarded = true
                    }
                    .font(.headline)
                }
            }
            .navigationTitle("Diksiyonunu kuralım")
        }
    }
}
