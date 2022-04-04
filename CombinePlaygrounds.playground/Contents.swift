import UIKit
import Combine

enum MyError: Error {
  case general
}

var subject1 = PassthroughSubject<String, Never>()

// sinkメソッドはsubscribeのこと
// sinkはエラー型をNever(失敗しない）にしたときにだけ使える
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
