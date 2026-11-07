import Foundation

enum Kind { case breath, steps, pace }

struct Step: Hashable {
    let title: String
    let text: String
    var quote: String? = nil
    var secs: Int? = nil
}

func St(_ t: String, _ x: String, q: String? = nil, s: Int? = nil) -> Step {
    Step(title: t, text: x, quote: q, secs: s)
}

struct Exercise: Identifiable, Hashable {
    let id: String
    let level: Int
    let minutes: Int
    let kind: Kind
    let title: String
    let desc: String
    var tags: [String] = []
    var steps: [Step] = []
    var lines: [String] = []
    var wpm: Int = 100
    var pattern: [Int] = [4, 1, 6, 0]
    var cycles: Int = 8
}

struct Level: Identifiable {
    let n: Int
    let title: String
    let sub: String
    var id: Int { n }
}

struct WeakOption: Identifiable {
    let key: String
    let label: String
    var id: String { key }
}

enum Content {
    static let levels: [Level] = [
        Level(n: 1, title: "Nefes ve duruş", sub: "Sesin yakıtı: rahat duruş, karın nefesi, uzun ve düzgün soluk."),
        Level(n: 2, title: "Ağız kasları", sub: "Çene, dudak ve dil gevşer; artikülasyon organları ısınır."),
        Level(n: 3, title: "Türkçe sesler", sub: "Sekiz ünlü ve zorlu ünsüzler: önce tek tek, sonra cümle içinde."),
        Level(n: 4, title: "Hece ve tekerleme", sub: "Hece zincirleri, uzun kelimeler ve hız merdiveni."),
        Level(n: 5, title: "Vurgu ve tonlama", sub: "Vurgu, soru ve bildirme tonu, duraklama, ses seviyesi."),
        Level(n: 6, title: "Akıcı konuşma", sub: "Okuma, hız kontrolü ve doğaçlama konuşma.")
    ]

    static let weakOptions: [WeakOption] = [
        WeakOption(key: "r", label: "R"),
        WeakOption(key: "l", label: "L"),
        WeakOption(key: "s", label: "S Ş Z Ç C"),
        WeakOption(key: "k", label: "K G Ğ H"),
        WeakOption(key: "p", label: "P B T D"),
        WeakOption(key: "vowel", label: "Ö Ü I (ünlüler)"),
        WeakOption(key: "speed", label: "Hız ve akıcılık"),
        WeakOption(key: "breath", label: "Nefesim yetmiyor"),
        WeakOption(key: "tone", label: "Monoton konuşuyorum")
    ]

    static let rateLabels = ["Zorlandım", "Zor", "Fena değil", "İyi", "Pürüzsüz"]

    static func steps(_ id: String, _ lv: Int, _ min: Int, _ title: String, _ desc: String, tags: [String] = [], _ steps: [Step]) -> Exercise {
        Exercise(id: id, level: lv, minutes: min, kind: .steps, title: title, desc: desc, tags: tags, steps: steps)
    }

    static func pace(_ id: String, _ lv: Int, _ min: Int, _ title: String, _ desc: String, tags: [String] = [], wpm: Int, _ lines: [String]) -> Exercise {
        Exercise(id: id, level: lv, minutes: min, kind: .pace, title: title, desc: desc, tags: tags, lines: lines, wpm: wpm)
    }

    static let all: [Exercise] = [
        steps("1.1", 1, 3, "Duruş ve gevşeme", "Konuşma bedenle başlar. Omuz ve boyun gergin olduğunda ses de gergin çıkar.", tags: ["breath"], [
            St("Ayakta dur", "Ayaklar omuz genişliğinde, dizler kilitli değil. Başın tavandan ince bir iple çekiliyormuş gibi dik dursun."),
            St("Omuzları bırak", "Omuzları kulaklarına doğru kaldır, 3 saniye tut, bırak. Birkaç kez tekrarla.", s: 20),
            St("Boynu gevşet", "Çeneni göğsüne indir, başını yavaşça sağa ve sola yarım daire gezdir. Boynu tam çevirme.", s: 30),
            St("Kaburga ve karın", "Bir elini kaburgalarının yanına, diğerini karnına koy. Nefes alırken ikisinin de dışarı açıldığını hisset. Omuzlar kalkmasın.")
        ]),
        Exercise(id: "1.2", level: 1, minutes: 3, kind: .breath, title: "Karın nefesi",
                 desc: "Burundan 4 saniye al, 1 saniye tut, ağızdan 6 saniye yavaşça ver. Omuzlar yerinde, karın dışarı açılsın.",
                 tags: ["breath"], pattern: [4, 1, 6, 0], cycles: 8),
        steps("1.3", 1, 3, "Uzun \"s\" ile soluk kontrolü", "Dişlerin arasından titremeden, eşit şiddette \"sssss\" sesi çıkar. Süre uzadıkça ses düzgün kalmalı.", tags: ["breath"], [
            St("10 saniye", "Derin karın nefesi al, \"sssss\" sesini düzgün tut.", s: 10),
            St("15 saniye", "Yeniden nefes al. Sesin sonunda zayıflamasın.", s: 15),
            St("20 saniye", "Aynı şiddette devam et. Omuzların kalkmasına izin verme.", s: 20),
            St("25 saniye", "Zorlanırsan süreyi kısalt. Hedef eşit ve kesintisiz soluk.", s: 25)
        ]),
        steps("1.4", 1, 2, "Kâğıt ve mum üfleme", "Soluğu tek yönde, sabit hızda boşaltmayı öğretir.", tags: ["breath"], [
            St("Kâğıt", "Bir kâğıt şeridi ağzının önünde tut. Üfleyerek onu 10 saniye boyunca aynı açıda tutmaya çalış.", s: 10),
            St("Mum gibi", "Önünde bir mum varmış gibi alevi eğ ama söndürme. Soluk akışı sabit kalsın.", s: 15)
        ]),
        pace("1.5", 1, 3, "Nefesi cümleye bağla", "Her satırı tek nefeste, acele etmeden oku. Cümle bitmeden nefes alma.", tags: ["breath"], wpm: 70, [
            "Sabah oldu.",
            "Güneş yavaşça yükseldi.",
            "Sokaktaki ağaçlar rüzgârla hafifçe sallandı.",
            "Eve dönerken fırından sıcak ekmek aldım ve yavaş yavaş yürüdüm."
        ]),
        steps("2.1", 2, 2, "Çene gevşetme", "Sıkı çene, kapalı ses demektir.", [
            St("Esneme", "İçten gelen bir esneme yap, çenenin aşağı sarktığını hisset.", s: 15),
            St("Aç-kapa", "Ağzını yavaşça aç ve kapat. 10 tekrar. Çenede takılma ya da ağrı olmamalı.", s: 20),
            St("Yana kaydır", "Çeneyi hafifçe sağa ve sola kaydır. Gevşek ve yavaş.", s: 15)
        ]),
        steps("2.2", 2, 3, "Dudak çalışması", "Dudaklar p, b, m, o, u, ö, ü seslerinin şeklini verir.", [
            St("Dudak titreşimi", "Dudakları gevşek bırakıp \"brrr\" diye titret. Nefesi sabit tut.", s: 20),
            St("Öpücük ve gülümseme", "Dudakları öne büz, sonra geniş gülümse. Abartarak tekrar et.", s: 20),
            St("Dudak hecesi", "Yüksek sesle ve net şekilde tekrar et.", q: "bü bü bü  pa pa pa  mo mo mo  vu vu vu", s: 25)
        ]),
        steps("2.3", 2, 3, "Dil çalışması", "Dil ucu; r, l, t, d, n, s, ş gibi seslerin ana oyuncusu.", [
            St("Dil ucu daire", "Dil ucunla dudakların etrafında yavaş daireler çiz, sonra diğer yöne.", s: 20),
            St("Yukarı aşağı", "Dilini çıkar, burnuna doğru kaldır, çeneye doğru indir. Çene sabit kalsın.", s: 20),
            St("Damak vuruşu", "Dil ucunu üst dişlerin arkasına vurarak tekrar et.", q: "la la la  ta ta ta  da da da  na na na", s: 25)
        ]),
        steps("2.4", 2, 4, "Kalem egzersizi", "Klasik diksiyon çalışması: kalemle konuşmak organları zorlar, kalem çıkınca konuşma belirgin hafifler.", [
            St("Kalemi yerleştir", "Temiz bir kalemi ya da mantarı dişlerinin arasına yatay tut. Dudaklar ona değmesin."),
            St("Kalemle oku", "Aşağıdaki metni kalem ağzındayken, olabildiğince anlaşılır oku.", q: "Sabah erken kalkıp sahile indim. Deniz sakindi, martılar suyun üstünde dönüyordu.", s: 60),
            St("Kalemi çıkar, aynı metni oku", "Aynı metni bu kez kalemsiz oku. Sesin ne kadar rahat ve net çıktığına dikkat et.", s: 45)
        ]),
        steps("2.5", 2, 5, "5 dakikalık ısınma rutini", "Her çalışma gününün başında kullanabileceğin kısa ısınma.", tags: ["breath"], [
            St("Karın nefesi", "Burundan nefes al, karnın açılsın, ağızdan yavaşça ver.", s: 60),
            St("Dudak ve yüz", "Dudak titreşimi yap, yüz kaslarını esnet, çeneyi gevşet.", s: 60),
            St("Ünlü uzatma", "Her ünlüyü uzatarak, ağız şeklini belirgin yap.", q: "a – e – ı – i – o – ö – u – ü", s: 90),
            St("İki üç tekerleme", "Yavaş başla, netliği koru.", q: "Şu köşe yaz köşesi, şu köşe kış köşesi, ortada su şişesi.", s: 60),
            St("Nefes merdiveni", "Derin nefes al, \"ssss\" diyerek soluğu eşit şekilde boşalt.", s: 30)
        ]),
        steps("3.1", 3, 5, "Sekiz ünlü", "Türkçede 8 ünlü var: a e ı i o ö u ü. Her birinin ağız şekli ayrı.", tags: ["vowel"], [
            St("A", "Ağız geniş, dil düz, dudak yuvarlak değil.", q: "kapı – ara – anne"),
            St("E", "Ağız orta açık, dudaklar hafif yana.", q: "el – deme – kebe"),
            St("I (noktasız)", "Dil geride, dudaklar düz, çene hafif aralık.", q: "ışık – kırık – sıcak"),
            St("İ", "Dil önde, dudaklar yana gerili.", q: "iş – ilik – işitmek"),
            St("O", "Dudaklar yuvarlak, dil geride.", q: "okul – ova – oyun"),
            St("Ö", "\"e\" de ve dudaklarını yuvarla. Dil önde kalır.", q: "öğle – ön – gözlük"),
            St("U", "Dudaklar küçük ve ileri, dil geride.", q: "uzun – kutu – uyku"),
            St("Ü", "\"i\" de ve dudaklarını büz.", q: "üzüm – gülüş – dünya")
        ]),
        pace("3.2", 3, 4, "Ünlü çiftleri", "Birbirine yakın ünlüleri ayır. Her çiftte ağız şeklinin değiştiğini hisset.", tags: ["vowel"], wpm: 60, [
            "kır kir  kul kül",
            "kor kör  ot öt",
            "tut tüt  kış kuş",
            "ılık ilik  ölçü ölçü",
            "uzun üzüm  ördek ırmak"
        ]),
        pace("3.3", 3, 4, "R ve L", "R: dil ucu damağa hızlı bir vuruş yapar. L: dil ucu üst dişlerin arkasında.", tags: ["r", "l"], wpm: 80, [
            "Lale lamba ve limon.",
            "Kırmızı araba virajı dikkatle döndü.",
            "Uzun yoldan dönen Selim gölde yüzdü.",
            "Sarı koltuk, kalın halı ve geniş bir salon.",
            "Kırk kuru kiraz, kırk bir kırmızı kiraz."
        ]),
        pace("3.4", 3, 4, "S, Ş, Z, Ç, C", "Sızıcı ve çarpmalı seslerde dil ve diş konumuna dikkat et. S ince, Ş geniş ve yuvarlak.", tags: ["s"], wpm: 80, [
            "Su sabah serinliğinde şişeye süzüldü.",
            "Şemsiyesini şişirip sokağa çıktı.",
            "Çok çabuk çay içip çarşıya çıktık.",
            "Cesur Cemal caddede ceviz sattı.",
            "Şu köşe yaz köşesi, şu köşe kış köşesi, ortada su şişesi."
        ]),
        pace("3.5", 3, 4, "K, G, Ğ, H", "K ve G, kalın ünlülerle kalın, ince ünlülerle ince söylenir. Ğ ünlüyü uzatır, H hafif ve gırtlaktan.", tags: ["k"], wpm: 80, [
            "Kitap, kalem, kâğıt, kutu.",
            "Göl kenarında güzel gül gördü.",
            "Dağ başında yağan yağmur ağaçları yıkadı.",
            "Hasan havuzda hâlâ hafifçe hırlıyordu."
        ]),
        pace("3.6", 3, 3, "P, B, T, D", "Patlayıcı sesler dudak ve dil ucunun net kapanıp açılmasını ister.", tags: ["p"], wpm: 80, [
            "Pazar pazarında bal, peynir ve balık bulduk.",
            "Dedem tatlıyı tabaktan tadıp durdu.",
            "Bir tabak patates, bir demet tere."
        ]),
        pace("4.1", 4, 3, "Hece zincirleri", "Sesleri hızlı ama bozulmadan art arda söylemeyi eğitir.", tags: ["speed"], wpm: 70, [
            "pa ta ka  pa ta ka  pa ta ka",
            "ba da ga  ba da ga  ba da ga",
            "la ra na  la ra na  la ra na",
            "şa sa ça  şa sa ça  şa sa ça",
            "pata kata  pata kata  pata kata"
        ]),
        pace("4.2", 4, 4, "Uzun kelimeler", "Her heceyi yutmadan söyle. Dil ve dudaklar sıralı çalışmalı.", tags: ["speed"], wpm: 70, [
            "Kalemtıraş kırmızı kirpik",
            "Anlayışlı düşünceli sorumluluk",
            "Gözlemlemek değerlendirmek geliştirmek",
            "Karşılaştırmak yapılandırmak uygulamak",
            "Muvaffakiyetsizleştiricileştiriveremeyebileceklerimizdenmişsinizcesine"
        ]),
        pace("4.3", 4, 4, "Kısa tekerlemeler", "Önce yavaş. Üç kez temiz söyleyince hızı %10 artır; üçüncüde sesler karışıyorsa hız değil kontrol çalış.", tags: ["speed"], wpm: 80, [
            "Şu köşe yaz köşesi, şu köşe kış köşesi, ortada su şişesi.",
            "Bir berber bir berbere gel birader beraber bir berber dükkânı açalım demiş."
        ]),
        pace("4.4", 4, 4, "Takatukacı", "Uzun ve ritimli bir halk tekerlemesi. Nefesini cümlelere böl.", tags: ["speed"], wpm: 80, [
            "Al bu takatukaları takatukacıya götür.",
            "Takatukacı bu takatukaları takatukalatmazsa",
            "al bu takatukaları takatukacıdan takatukalatmadan geri getir."
        ]),
        pace("4.5", 4, 4, "Hız merdiveni", "Tek cümleyi kademeli hızlandır. Hedef: 150 kelime/dk civarında hâlâ net olmak.", tags: ["speed"], wpm: 90, [
            "Kırk kırık küp kırık küpçüde kırıldı, küpçü küpleri toparlayıp küçük kutuya koydu."
        ]),
        steps("5.1", 5, 4, "Vurguyu kaydır", "Aynı cümlede vurgulanan kelime anlamı değiştirir. Her adımda büyük harfli kelimeyi belirgin söyle.", tags: ["tone"], [
            St("Kim?", "Başka biri değil, Ali gidiyor.", q: "ALİ yarın İstanbul'a gidiyor."),
            St("Ne zaman?", "Bugün değil, yarın.", q: "Ali YARIN İstanbul'a gidiyor."),
            St("Nereye?", "Başka şehre değil.", q: "Ali yarın İSTANBUL'A gidiyor."),
            St("Ne yapıyor?", "Gelmiyor, gidiyor.", q: "Ali yarın İstanbul'a GİDİYOR.")
        ]),
        pace("5.2", 5, 4, "Bildirme, soru, ünlem", "Bildirmede ses sonda iner. Soruda soru ekinden önceki hece vurgulanır ve ton yükselir. Ünlemde enerji artar.", tags: ["tone"], wpm: 70, [
            "Yarın toplantı var.",
            "Yarın toplantı mı var?",
            "Yarın toplantı var!",
            "Elma, armut, kiraz ve üzüm."
        ]),
        pace("5.3", 5, 4, "Duraklama ve nefes", "Çizgiler (|) kısa duraklamadır. Duraklamada nefes al ve düşünceyi bitir.", tags: ["tone"], wpm: 80, [
            "Sabah erkenden kalktım | pencereyi açtım | ve serin havayı içime çektim.",
            "Sokak henüz uykudaydı || ama fırından çıkan ekmeğin kokusu | çoktan mahalleye yayılmıştı."
        ]),
        steps("5.4", 5, 5, "Ses seviyesi merdiveni", "Aynı cümleyi 6 farklı şiddette oku; netlik hep aynı kalsın.", tags: ["tone"], [
            St("Çok kısık fısıltı", "Neredeyse duyulmayacak, ama sesler net.", q: "Güneşin ilk ışıkları denize düştü."),
            St("Fısıltı", "Yanındaki duysun.", q: "Güneşin ilk ışıkları denize düştü."),
            St("Sakin konuşma", "Samimi bir sohbet.", q: "Güneşin ilk ışıkları denize düştü."),
            St("Normal ses", "Gündelik konuşma gücü.", q: "Güneşin ilk ışıkları denize düştü."),
            St("Yansıtılmış ses", "Küçük bir odaya hitap et.", q: "Güneşin ilk ışıkları denize düştü."),
            St("Tam projeksiyon", "Büyük bir salonu doldur, bağırma. Destek karından gelsin.", q: "Güneşin ilk ışıkları denize düştü.")
        ]),
        pace("6.1", 6, 5, "Okuma metni 1", "Rahat bir tempoda, anlamı vurgulayarak oku.", tags: ["speed"], wpm: 100, [
            "Sabahın ilk ışıkları pencereden içeri süzülürken kahvenin kokusu bütün eve yayıldı.",
            "Bugün yapılacak çok iş vardı | ama acele etmeden, tane tane başlamak istiyordum."
        ]),
        pace("6.2", 6, 5, "Haber okuma", "Haber spikeri temposu: net, düz, vurguları yerinde.", tags: ["speed"], wpm: 115, [
            "Meteoroloji uzmanları | hafta sonu için yurdun kuzey bölgelerinde kuvvetli yağış beklendiğini duyurdu.",
            "Vatandaşların ulaşım planlarını buna göre yapması önerildi.",
            "Gün boyunca rüzgârın kuzeybatıdan hafif, zaman zaman kuvvetli esmesi bekleniyor."
        ]),
        pace("6.3", 6, 4, "Hız kontrolü", "Aynı cümleyi yavaştan hızlıya oku ve her hızda anlaşılır kal.", tags: ["speed"], wpm: 90, [
            "Dün akşam arkadaşlarımla sahilde uzun uzun yürüyüş yaptık."
        ]),
        steps("6.4", 6, 5, "1 dakikalık doğaçlama", "Okumadan, kendi cümlelerinle konuş. \"Yani, işte, şey\" gibi dolgulara dikkat et.", tags: ["tone"], [
            St("Konu seç", "Birini seç: çocukluğundan bir koku, en sevdiğin yemek, hayatındaki dönüm noktası, mutlu bir yolculuk."),
            St("Düşün", "Üç ana fikir belirle. Giriş, gelişme, sonuç.", s: 15),
            St("Konuş", "Tane tane, duraklamalarla konuş. Dolgu kelimesini duraklamayla değiştir.", s: 60),
            St("Değerlendir", "Hangi bölümde acele ettin? Hangi kelimeler karıştı? Aynı konuyu bir kez daha, daha yavaş anlat.")
        ]),
        pace("6.5", 6, 6, "Günlük okuma", "Kendini kaydet ve dinle. En çok işe yarayan geri bildirim budur.", tags: ["speed"], wpm: 125, [
            "Konuşmak bir beceridir ve her beceri gibi düzenli çalışmayla gelişir.",
            "Her gün biraz nefes, biraz ses, biraz da dikkat. | Zamanla sesin sana daha çok uyar.",
            "Kendini dinlemek ilk adımdır | çünkü duyduğun şeyi düzeltebilirsin."
        ])
    ]

    static let byId: [String: Exercise] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
}
