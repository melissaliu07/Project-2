import SwiftUI

struct Holiday: Codable, Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let isCustom: Bool
}

class CalendarViewModel: ObservableObject {
    @Published var holidays: [Holiday] = []
    
    func fetchHolidays(for year: Int, country: String) {
        let apiKey = "lsat36VBnxqbtPnUMhuFxAcddqF0sk6N"
        let urlString = "https://calendarific.com/api/v2/holidays?api_key=\(apiKey)&country=\(country)&year=\(year)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CalendarResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.holidays = result.response.holidays.map { Holiday(name: $0.name, date: $0.date.iso, isCustom: false) }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    
    func addCustomEvent(name: String, date: String) {
        let newEvent = Holiday(name: name, date: date, isCustom: true)
        holidays.append(newEvent)
        holidays.sort { $0.date < $1.date }
    }
    
    func removeEvent(at offsets: IndexSet) {
        holidays.remove(atOffsets: offsets)
    }
}

struct CalendarResponse: Codable {
    let response: Response
}

struct Response: Codable {
    let holidays: [HolidayResponse]
}

struct HolidayResponse: Codable {
    let name: String
    let date: DateResponse
}

struct DateResponse: Codable {
    let iso: String
}

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedCountry = "US"
    @State private var showingAddEvent = false
    @State private var newEventName = ""
    @State private var newEventDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.holidays) { holiday in
                    VStack(alignment: .leading) {
                        Text(holiday.name)
                            .font(.headline)
                        Text(holiday.date)
                            .font(.subheadline)
                        if holiday.isCustom {
                            Text("Custom Event")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onDelete(perform: viewModel.removeEvent)
            }
            .navigationTitle("Calendar Events")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fetch Holidays") {
                        viewModel.fetchHolidays(for: selectedYear, country: selectedCountry)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Custom Event") {
                        showingAddEvent = true
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(viewModel: viewModel)
            }
        }
    }
}

struct AddEventView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var eventName = ""
    @State private var eventDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Event Name", text: $eventName)
                DatePicker("Date", selection: $eventDate, displayedComponents: .date)
            }
            .navigationTitle("Add Custom Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    viewModel.addCustomEvent(name: eventName, date: formatter.string(from: eventDate))
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

