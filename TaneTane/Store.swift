import Foundation
import SwiftUI

struct Record: Codable {
    var rating: Int
    var date: Date
    var count: Int
}

struct AppState: Codable {
    var onboarded = false
    var minutes = 10
    var weak: [String] = []
    var startLevel = 1
    var done: [String: Record] = [:]
    var days: [String: Int] = [:]
    var wpm: [String: Int] = [:]
}

extension Color {
    static let tane = Color(red: 0.05, green: 0.52, blue: 0.45)
}

final class Store: ObservableObject {
    @Published var s: AppState {
        didSet { save() }
    }
    private let key = "tane_state_v1"

    init() {
        if let d = UserDefaults.standard.data(forKey: "tane_state_v1"),
           let st = try? JSONDecoder().decode(AppState.self, from: d) {
            s = st
        } else {
            s = AppState()
        }
    }

    private func save() {
        if let d = try? JSONEncoder().encode(s) {
            UserDefaults.standard.set(d, forKey: key)
        }
    }

    // MARK: Tarih yardımcıları

    func dayKey(_ d: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: d)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    func daysSince(_ d: Date) -> Int {
        let cal = Calendar.current
        let a = cal.startOfDay(for: d)
        let b = cal.startOfDay(for: Date())
        return cal.dateComponents([.day], from: a, to: b).day ?? 0
    }

    // MARK: Seviye mantığı

    func exercises(in level: Int) -> [Exercise] {
        Content.all.filter { $0.level == level }
    }

    func rating(_ e: Exercise) -> Int? { s.done[e.id]?.rating }

    func cleared(_ level: Int) -> Bool {
        if level < 1 { return true }
        return exercises(in: level).allSatisfy { (s.done[$0.id]?.rating ?? 0) >= 3 }
    }

    func unlocked(_ level: Int) -> Bool {
        level <= s.startLevel || cleared(level - 1)
    }

    var currentLevel: Int {
        for l in 1...6 where unlocked(l) && !cleared(l) { return l }
        return 6
    }

    func isDoneToday(_ e: Exercise) -> Bool {
        guard let r = s.done[e.id] else { return false }
        return Calendar.current.isDateInToday(r.date)
    }

    func streak() -> Int {
        let cal = Calendar.current
        var n = 0
        var d = Date()
        if (s.days[dayKey(d)] ?? 0) == 0 {
            d = cal.date(byAdding: .day, value: -1, to: d) ?? d
        }
        while (s.days[dayKey(d)] ?? 0) > 0 {
            n += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: d) else { break }
            d = prev
        }
        return n
    }

    func totalMinutes() -> Int { s.days.values.reduce(0, +) }

    // MARK: Günün planı

    func planToday() -> [Exercise] {
        var out: [Exercise] = []
        var used = 0
        let budget = s.minutes

        func add(_ e: Exercise?) {
            guard let e = e, !out.contains(e) else { return }
            if !out.isEmpty && used + e.minutes > budget { return }
            out.append(e)
            used += e.minutes
        }

        add(Content.byId[(budget >= 15 && unlocked(2)) ? "2.5" : "1.2"])
        let open = Content.all.filter { unlocked($0.level) }

        let redo = open.filter { (s.done[$0.id]?.rating ?? 5) < 3 }
            .sorted { (s.done[$0.id]?.date ?? Date()) < (s.done[$1.id]?.date ?? Date()) }
        for e in redo { add(e) }

        let weakHits = open.filter { e in
            let hit = e.tags.contains(where: { s.weak.contains($0) })
            let stale = s.done[e.id].map { daysSince($0.date) >= 2 } ?? true
            return hit && stale
        }
        for e in weakHits.prefix(2) { add(e) }

        for e in exercises(in: currentLevel) where s.done[e.id] == nil { add(e) }
        for e in open where s.done[e.id] == nil { add(e) }
        return out
    }

    // MARK: Kayıt

    func record(_ e: Exercise, rating: Int) -> String {
        let wasCleared = cleared(e.level)
        let prev = s.done[e.id]?.count ?? 0
        s.done[e.id] = Record(rating: rating, date: Date(), count: prev + 1)
        let k = dayKey(Date())
        s.days[k] = (s.days[k] ?? 0) + e.minutes
        var m = rating < 3
            ? "Bu çalışma planına tekrar olarak girecek. Yavaşlamak tamamen normal."
            : "Güzel iş."
        if !wasCleared && cleared(e.level) {
            m += " Seviye \(e.level) tamamlandı"
            m += e.level < 6 ? ", Seviye \(e.level + 1) açıldı." : "."
        }
        return m
    }

    func reset() { s = AppState() }
}
