import UIKit
import Combine

enum MyError: Error {
  case general
}

var subject1 = PassthroughSubject<String, Never>()

// sinkメソッドはsubscribeのこと
// sinkの1引数版はエラー型をNever(失敗しない）にしたときにだけ使える
subject1
  .sink { value in
    print("Received value:", value)
  }

subject1.send("a")
subject1.send("b")
subject1.send("c")
subject1.send("d")
subject1.send("e")

print("--------------------------")

let subject2 = PassthroughSubject<String, MyError>()

// 2引数をとるsinkはエラー型が任意で使える
subject2
  .sink(receiveCompletion: { completion in
    print("Received completion:", completion)
  }, receiveValue: { value in
    print("Received value:", value)
  })

subject2.send("a")
subject2.send("b")
subject2.send("c")
//subject2.send(completion: .finished)
subject2.send(completion: .failure(.general))
subject2.send("d")
subject2.send("e")

print("--------------------------")

let subject3 = PassthroughSubject<String, Never>()

class Receiver {
  let subscription: AnyCancellable
  
  init() {
    // この記述だと購読が解除される
    // initのスコープ内でのみ参照可能のため、initが完了するとメモリ解放がされる
//    subject3
//      .sink(receiveCompletion: { completion in
//        print("Received completion:", completion)
//      }, receiveValue: { value in
//        print("Received value:", value)
//      })
    
    // sinkの返り値を保持すると購読状態が保たれる
    // sinkはsubscriptionの一種
    subscription = subject3
      .sink(receiveCompletion: { completion in
        print("Received completion:", completion)
      }, receiveValue: { value in
        print("Received value:", value)
      })
  }
}

print("出力される？")

let receiver = Receiver()
subject3.send("a")
subject3.send("b")
// AnyCancellableは購読キャンセル可能
receiver.subscription.cancel()
subject3.send("c")
subject3.send(completion: .finished)

print("--------------------------")

// 複数のsubscription

let subject4 = PassthroughSubject<String, Never>()

class Receiver2 {
  let subscription1: AnyCancellable
  let subscription2: AnyCancellable
  
  init() {
    subscription1 = subject4.sink(receiveValue: { value in
      print("Value:", value)
    })
    subscription2 = subject4.sink(receiveValue: { value in
      print("Value:", value)
    })
  }
}

let receiver2 = Receiver2()
subject4.send("a")
subject4.send("b")
// 片方だけキャンセル
receiver2.subscription1.cancel()
subject4.send("c")
subject4.send(completion: .finished)

print("--------------------------")

// storeメソッドについて
// 複数のsubscriptionをまとめて保持するときに便利

let subject5 = PassthroughSubject<String, Never>()

class Receiver3 {
  // storeメソッドを使う場合はvarにする
  var subscriptions = Set<AnyCancellable>()
  
  init() {
    subject5
      .sink { value in
        print("value:", value)
      }
      .store(in: &subscriptions)
    
    subject5
      .sink { value in
        print("value:", value)
      }
      .store(in: &subscriptions)
  }
}

let receiver3 = Receiver3()
subject5.send("a")
subject5.send("b")
subject5.send("c")
subject5.send(completion: .finished)

print("--------------------------")

// assingメソッド
// subscriptionの一種
// クロージャ処理の代わりにオブジェクトを指定している（バインド？）
// assignは失敗しないsubjectでしか使えない

let subject6 = PassthroughSubject<String, Never>()

final class SomeObject {
  // toに指定されるプロパティはミュータブルであること！
  var value: String = "" {
    didSet {
      print("didSet value", value)
    }
  }
}

final class Receiver4 {
  var subscriptions = Set<AnyCancellable>()
  let object = SomeObject()
  
  init() {
    subject6
      .assign(to: \.value, on: object)
      .store(in: &subscriptions)
  }
}

let receiver4 = Receiver4()
subject6.send("a")
subject6.send("b")
subject6.send("c")

