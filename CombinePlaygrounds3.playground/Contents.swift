import UIKit
import Combine

print("バインディングについて")

print("------------------------")

final class Model {
  @Published var value: String = "0"
}

let model = Model()

final class ViewModel {
  var text: String = "" {
    didSet {
      print("didSet text:", text)
    }
  }
}

final class Receiver {
  var subscriptions = Set<AnyCancellable>()
  let viewModel = ViewModel()
  
  init() {
    model.$value
      .assign(to: \.text, on: viewModel)
      .store(in: &subscriptions)
  }
}

let receiver = Receiver()
model.value = "1"
model.value = "2"
model.value = "3"
model.value = "4"

print("------------------------")

final class ModelInt {
  @Published var int: Int = 0
}

let modelInt = ModelInt()

final class Receiver2 {
  var subscriptions = Set<AnyCancellable>()
  let viewModel = ViewModel()
  
  init() {
    modelInt.$int
      .filter { $0 < 3 }
      .map { $0.description }
      .assign(to: \.text, on: viewModel)
      .store(in: &subscriptions)
  }
}

let receiver2 = Receiver2()
modelInt.int = 1
modelInt.int = 2
modelInt.int = 3
modelInt.int = 4

// 他にも compactMap や combineLatest などがある
