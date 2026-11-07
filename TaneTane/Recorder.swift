import SwiftUI
import AVFoundation

@MainActor
final class VoiceRecorder: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var hasRecording = false
    @Published var denied = false

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    private var url: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("tane_take.m4a")
    }

    func toggleRecord() {
        if isRecording {
            recorder?.stop()
            isRecording = false
            hasRecording = true
            return
        }
        player?.stop()
        isPlaying = false
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted { self.startRecording() } else { self.denied = true }
            }
        }
    }

    private func startRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            isRecording = true
        } catch {
            isRecording = false
        }
    }

    func togglePlay() {
        if isPlaying {
            player?.stop()
            isPlaying = false
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }
}

struct RecorderBar: View {
    @StateObject private var rec = VoiceRecorder()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kendini kaydet").font(.headline)
            HStack {
                Button {
                    rec.toggleRecord()
                } label: {
                    Label(rec.isRecording ? "Kaydı durdur" : "Kaydet",
                          systemImage: rec.isRecording ? "stop.circle.fill" : "mic.circle")
                }
                .buttonStyle(.bordered)
                .tint(rec.isRecording ? .red : Color.tane)

                if rec.hasRecording && !rec.isRecording {
                    Button {
                        rec.togglePlay()
                    } label: {
                        Label(rec.isPlaying ? "Durdur" : "Dinle",
                              systemImage: rec.isPlaying ? "pause.circle" : "play.circle")
                    }
                    .buttonStyle(.bordered)
                }
            }
            if rec.denied {
                Text("Mikrofon izni verilmedi. Ayarlar > Tane Tane bölümünden açabilirsin.")
                    .font(.footnote).foregroundStyle(.red)
            } else {
                Text("Kayıt yalnızca telefonda geçici olarak tutulur, uygulama kapanınca silinir.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }
}
