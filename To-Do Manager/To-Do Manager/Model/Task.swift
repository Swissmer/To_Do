import Foundation

// приоритет
enum TaskPriority {
    // нормальный
    case normal
    // высокий
    case high
}

// статус
enum TaskStatus: Int {
    // запланированная
    case planned
    // завершённая
    case comleted
}

// требование к типу Task
protocol TaskProtocol {
    // название
    var title: String { get set }
    // приоритет
    var type: TaskPriority { get set }
    // статус
    var status: TaskStatus { get set }
}

// сущность "Задача"
struct Task: TaskProtocol {
    var title: String
    var type: TaskPriority
    var status: TaskStatus
}
