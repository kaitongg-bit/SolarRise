import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \DailyRecord.date, order: .reverse) private var records: [DailyRecord]
    @State private var viewMode: ViewMode = .calendar
    
    enum ViewMode {
        case calendar
        case list
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header & Mode Switcher
                VStack(spacing: 20) {
                    Text("成长历程")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .padding(.top, 20)
                    
                    Picker("View Mode", selection: $viewMode) {
                        Image(systemName: "calendar").tag(ViewMode.calendar)
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
                .padding(.bottom, 24)
                
                if records.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "sun.haze")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.2))
                        Text("尚无挑战记录")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    Spacer()
                } else {
                    if viewMode == .calendar {
                        CalendarView(records: records)
                    } else {
                        ListView(records: records)
                    }
                }
            }
        }
    }
}

struct CalendarView: View {
    let records: [DailyRecord]
    @State private var currentMonth = Date()
    private let calendar = Calendar.current
    private let daysInWeek = ["日", "一", "二", "三", "四", "五", "六"]
    
    // Computed stats for the current month
    var monthlyStats: (success: Int, failed: Int, amount: Int) {
        let monthRecords = records.filter {
            calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month)
        }
        let success = monthRecords.filter { $0.status == .success || $0.status == .redeemed }.count
        let failed = monthRecords.filter { $0.status == .failed }.count
        let profit = monthRecords.reduce(0) { total, record in
            if record.status == .success { return total + Int(Double(record.betAmount) * 0.05) }
            if record.status == .failed { return total - record.betAmount }
            if record.status == .redeemed { return total - Int(Double(record.betAmount) * 1.5) } // Loss covered
            return total
        }
        return (success, failed, profit)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Calendar Header & Navigator
                HStack {
                    Button(action: {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    // Date Picker Title
                    ZStack {
                        Text(currentMonth.formatted(.dateTime.year().month(.wide)))
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.black.opacity(0.8))
                        
                        // Invisible DatePicker overlay
                        DatePicker("", selection: $currentMonth, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorMultiply(.clear) // Hide default UI
                            .background(Color.clear)
                            .frame(width: 120, height: 40)
                            .clipShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 8)
                
                // Calendar Grid
                MonthGridView(month: currentMonth, records: records)
                
                // Monthly Analytics Card (Premium UI)
                VStack(spacing: 16) {
                    Text("本月摘要")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 0) {
                        VStack(spacing: 4) {
                            Text("\(monthlyStats.success)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                            Text("成功唤醒")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider().frame(height: 30)
                        
                        VStack(spacing: 4) {
                            Text("\(monthlyStats.failed)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.red.opacity(0.8))
                            Text("赖床反悔")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider().frame(height: 30)
                        
                        VStack(spacing: 4) {
                            Text(monthlyStats.amount >= 0 ? "+\(monthlyStats.amount)" : "\(monthlyStats.amount)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(monthlyStats.amount >= 0 ? Color(hex: "FFD700") : .gray)
                            Text("光点盈亏")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    .shadow(color: Color.black.opacity(0.03), radius: 10, y: 5)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }
}

struct MonthGridView: View {
    let month: Date
    let records: [DailyRecord]
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 16) {
            let days = generateDaysInMonth(for: month)
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, record: findRecord(for: date), isCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month))
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(.white).shadow(color: .black.opacity(0.02), radius: 10, y: 5))
        .transition(.opacity) // Smooth fade transition for month switching
    }
    
    func findRecord(for date: Date) -> DailyRecord? {
        records.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func generateDaysInMonth(for month: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return [] }
        
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        var days: [Date?] = Array(repeating: nil, count: weekday - 1)
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

struct DayCell: View {
    let date: Date
    let record: DailyRecord?
    var isCurrentMonth: Bool = true // Default to true if not specified
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            if let record = record {
                Circle()
                    .fill(statusColor(record.status).opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: statusIcon(record.status))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(statusColor(record.status))
                    .offset(x: 10, y: -10)
            }
            
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 15, weight: calendar.isDateInToday(date) ? .bold : .medium))
                .foregroundColor(textColor(for: record))
        }
        .frame(height: 40)
        .opacity(isCurrentMonth ? 1.0 : 0.3) // Fade out non-current month days
    }
    
    func textColor(for record: DailyRecord?) -> Color {
        if calendar.isDateInToday(date) { return .orange }
        if record != nil { return .black }
        return .gray.opacity(0.3)
    }
    
    func statusIcon(_ status: ChallengeStatus) -> String {
        switch status {
        case .success: return "sun.max.fill"
        case .failed: return "xmark"
        case .redeemed: return "flame.fill"
        case .pending: return "ellipsis"
        }
    }
    
    func statusColor(_ status: ChallengeStatus) -> Color {
        switch status {
        case .success: return .green
        case .failed: return .red
        case .redeemed: return .orange
        case .pending: return .gray.opacity(0.3)
        }
    }
}

// MARK: - List View
struct ListView: View {
    let records: [DailyRecord]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(records) { record in
                    HistoryRow(record: record)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

struct HistoryRow: View {
    let record: DailyRecord
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(statusBgColor(record.status))
                    .frame(width: 44, height: 44)
                
                Image(systemName: statusIcon(record.status))
                    .foregroundColor(statusColor(record.status))
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.date.formatted(date: .long, time: .omitted))
                    .font(.system(size: 16, weight: .medium))
                Text(statusText(record.status))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                if record.status == .redeemed {
                    Text("挽回")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.orange.opacity(0.1)))
                        .foregroundColor(.orange)
                } else {
                    Text("\(record.status == .success ? "+" : "-")\(record.betAmount)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(statusColor(record.status))
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 12))
                        .foregroundColor(statusColor(record.status))
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white).shadow(color: .black.opacity(0.02), radius: 10, y: 5))
    }
    
    func statusColor(_ status: ChallengeStatus) -> Color {
        switch status {
        case .success: return .green
        case .failed: return .red
        case .redeemed: return .orange
        case .pending: return .gray
        }
    }
    
    func statusBgColor(_ status: ChallengeStatus) -> Color {
        statusColor(status).opacity(0.1)
    }
    
    func statusIcon(_ status: ChallengeStatus) -> String {
        switch status {
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .redeemed: return "flame.fill"
        case .pending: return "questionmark.circle"
        }
    }
    
    func statusText(_ status: ChallengeStatus) -> String {
        switch status {
        case .success: return "挑战成功"
        case .failed: return "挑战失败"
        case .redeemed: return "重燃成功"
        case .pending: return "待定"
        }
    }
}
