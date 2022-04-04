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
