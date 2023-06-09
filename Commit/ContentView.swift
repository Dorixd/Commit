import SwiftUI


struct ContentView: View {
    @StateObject private var habits = Habits()
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Commit your habits!")
            
            ForEach(habits.habits, id: \.id) { habit in
                HabitView(habit: $habits.habits[habits.habits.firstIndex(where: { $0.id == habit.id })!])
            }
            HabitOverviewView(habits: $habits.habits)
            
//            HStack(alignment: .center) {
////                HabitTrackerView(habits: $habits.habits)
//
//            }
        }
        .padding()
        .frame(width: 400, height: 400)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    isEditing.toggle()
                    habits.habits.indices.forEach { index in
                        habits.habits[index].isEditing = isEditing
                    }
                }) {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
        }
    }
}

class Habits: ObservableObject {
    @Published var habits: [Habit] = [
        Habit(title: "习惯1"),
        Habit(title: "习惯2"),
        Habit(title: "习惯3")
    ]
}

struct Habit: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var isEditing: Bool

    init(title: String, isCompleted: Bool = false, isEditing: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
        self.isEditing = isEditing
    }
}


struct HabitView: View {
    @Binding var habit: Habit
    
    var body: some View {
        Button(action: {
            if habit.isEditing {
                habit.isEditing.toggle()
            } else {
                habit.isCompleted.toggle()
            }
        }) {
            HStack(alignment: .center) {
                Spacer(minLength: 10) // 在文本前面添加一个 Spacer
                RoundedRectangle(cornerRadius: 5)
                    .fill(habit.isCompleted ? Color.green : Color.white)
                    .frame(width: 20, height: 20)
                if habit.isEditing {
                    TextField("Enter habit title", text: $habit.title, onCommit: {
                        habit.isEditing.toggle()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 220) // 设置一个固定宽度
                } else {
                    Text(habit.title)
                        .frame(width: 220, alignment: .leading) // 设置一个固定宽度，左对齐
                }
            }
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HabitTrackerView: View {
    @Binding var habits: [Habit]
    var body: some View {
        Rectangle()
            .fill(Color.green.opacity(Double(habits.filter { $0.isCompleted }.count) / Double(habits.count)))
            .frame(width: 50, height: 50)
    }
}

struct HabitOverviewView: View {
    @Binding var habits: [Habit]

    let calendar = Calendar.current
    let today = Date()

    func daysInMonth(date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }

    func firstWeekdayOfMonth(date: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstDayOfMonth = calendar.date(from: components)!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        let offset = firstWeekday - calendar.firstWeekday
        return offset >= 0 ? offset : (7 + offset)
    }

    func colorForDay(index: Int) -> Color {
        let currentDay = calendar.component(.day, from: today)
        if index == currentDay - 1 {
            let completedHabitsCount = habits.filter { $0.isCompleted }.count
            let totalHabitsCount = habits.count

            if completedHabitsCount == 0 {
                return Color.white
            } else {
                let colorIntensity = CGFloat(completedHabitsCount) / CGFloat(totalHabitsCount)
                return Color.green.opacity(colorIntensity)
            }
        } else {
            return Color.white
        }
    }

    func calendarView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(0..<(daysInMonth(date: today) + firstWeekdayOfMonth(date: today))).chunked(7), id: \.self) { week in
                HStack {
                    ForEach(week, id: \.self) { day in
                        if day < firstWeekdayOfMonth(date: today) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.clear)
                                .frame(width: 20, height: 20)
                        } else {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(colorForDay(index: day - firstWeekdayOfMonth(date: today)))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        calendarView()
    }
}

extension Array {
    func chunked(_ size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
