import UIKit
import Combine

// イベントを送信するオブジェクトのことを Publisher と呼ぶ
// また、イベントを送信することを publish と呼ぶ
// PassthroughSubject も Publisher の一つ

print("-------------------------")

// SwiftのSequenceプロトコルに .publisher プロパティがある
let arr = ["a", "b", "c", "d"]
let publisher1 = arr.publisher

final class Receiver1 {
  var subscriptions = Set<AnyCancellable>()
  
  init() {
    publisher1
      .sink(receiveCompletion: { completion in
        print("Received completion:", completion)
      }, receiveValue: { value in
        print("Received value:", value)
      })
      .store(in: &subscriptions)
  }
}

let receiver1 = Receiver1()

// Publisher1は "a", "b", ..., "d" と順番に publish する
// 最後に .finished を publish

// Publisher1 の型は Publishers.Sequence<[String], Never>

print("-------------------------")

let range = (1...5)
let publisher2 = range.publisher

final class Receiver2 {
  var subscriptions = Set<AnyCancellable>()
  
  init() {
    publisher2
      .sink(receiveCompletion: { completion in
        print("Received completion:", completion)
      }, receiveValue: { value in
        print("Received value:", value)
      })
      .store(in: &subscriptions)
  }
}

let receiver2 = Receiver2()

print("-------------------------")

let timerPublisherExample = false
let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
final class Receiver3 {
  var subscriptions = Set<AnyCancellable>()
  
  init() {
    timerPublisher
      .autoconnect()  // 自動で connect() が呼ばれる
      .sink(receiveValue: { value in
        print("Received value:", value)
      })
      .store(in: &subscriptions)
  }
}
if timerPublisherExample {
  let receiver3 = Receiver3()
  
  // Timer.TimerPublisher は connect() を呼ばないと subscribe されない
  //timerPublisher.connect()
} else {
  print("TimerPublisherExample was skipped.")
}

print("-------------------------")

// NotificationCenterのPublisher

extension Notification.Name {
  static let my = Notification.Name("MyNotification")
}
let notificationCenter = NotificationCenter.default
let notificationCenterPublisher = notificationCenter.publisher(for: .my)

final class Receiver4 {
  var subscriptions = Set<AnyCancellable>()
  
  init() {
    notificationCenterPublisher
      .sink(receiveValue: { value in
        print("Received value:", value)
      })
      .store(in: &subscriptions)
  }
}

let receiver4 = Receiver4()
NotificationCenter.default.post(.init(name: .my))

print("-------------------------")

// URLSession の Publisher

let sessionPublisherExample = false
let url = URL(string: "https://www.google.com/")!
let sessionPublisher = URLSession.shared.dataTaskPublisher(for: url)

final class Receiver5 {
  var subscriptions = Set<AnyCancellable>()
  
  init() {
    sessionPublisher
      .sink(receiveCompletion: { completion in
        // SessionのPublisherはエラーを返す場合がある
        if case let .failure(error) = completion {
          print("Received error:", error)
        } else {
          print("Received completion:", completion)
        }
      }, receiveValue: { data, response in
        print("Received data:", data)
        print("Received response:", response)
      })
      .store(in: &subscriptions)
  }
}

if sessionPublisherExample {
  let receiver5 = Receiver5()
} else {
  print("SessionPublisherExample was skipped.")
}

print("-------------------------")

// CurrentValueSubject - RxSwift の BehaviorSubject と似たようなもの

let currentValueSubject = CurrentValueSubject<String, Never>("A")

final class Receiver6 {
  var subscriptions = Set<AnyCancellable>()
  
  init() {
    currentValueSubject
      .sink(receiveValue: { value in
        print("Received value:", value)
      })
      .store(in: &subscriptions)
  }
}

let receiver6 = Receiver6()
currentValueSubject.send("B")
currentValueSubject.send("C")
currentValueSubject.send("D")
print("The value of currentValueSubject:", currentValueSubject.value)

print("-------------------------")

// PassthroughSubject - PublishSubjectに似ているがsubscribeした時点では値は流れない

let ptSubject = PassthroughSubject<String, Never>()
ptSubject.send("A")

final class Receiver7 {
  var subscriptins = Set<AnyCancellable>()
  
  init() {
    ptSubject
      .sink(receiveValue: { value in
        print("Received value:", value)
      })
      .store(in: &subscriptins)
  }
}


let receiver7 = Receiver7()
ptSubject.send("B")
ptSubject.send("C")
ptSubject.send("D")

print("-------------------------")


