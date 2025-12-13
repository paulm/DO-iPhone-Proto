import Foundation
import SwiftUI

// MARK: - Visit Type

enum VisitType {
    case city           // New city visits
    case place          // Notable places (>20min duration)
    case home           // Home visits
    case work           // Work visits
}

// MARK: - Visit Model

struct Visit: Identifiable {
    let id: UUID
    let type: VisitType
    let name: String              // e.g., "Salt Lake City" or "Whole Foods Market"
    let location: String?         // e.g., "Park City, Utah" (for places only)
    let subtitle: String?         // e.g., "Mayne House" (for home/work)
    let icon: DayOneIcon
    let time: String              // e.g., "7:44 AM"
    let duration: String          // e.g., "3 hours" or "45 min"
    let latitude: Double
    let longitude: Double

    init(
        id: UUID = UUID(),
        type: VisitType,
        name: String,
        location: String? = nil,
        subtitle: String? = nil,
        icon: DayOneIcon,
        time: String,
        duration: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.location = location
        self.subtitle = subtitle
        self.icon = icon
        self.time = time
        self.duration = duration
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Sample Data Generator

extension Visit {
    static func generateRandomVisits(for date: Date = Date()) -> [Visit] {
        // Seed random number generator with date for consistent results per day
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let seed = (components.year ?? 0) * 10000 + (components.month ?? 0) * 100 + (components.day ?? 0)
        srand48(seed)

        // Sample data pools with coordinates (Salt Lake City area)
        let cityData: [(name: String, icon: DayOneIcon, lat: Double, lon: Double)] = [
            ("Salt Lake City", .map_pin_filled, 40.7608, -111.8910),
            ("Park City", .map_pin_filled, 40.6461, -111.4980),
            ("Provo", .map_pin_filled, 40.2338, -111.6585),
            ("Barcelona", .map_pin_filled, 41.3851, 2.1734),
            ("Tokyo", .map_pin_filled, 35.6762, 139.6503),
            ("London", .map_pin_filled, 51.5074, -0.1278),
            ("Paris", .map_pin_filled, 48.8566, 2.3522),
            ("New York", .map_pin_filled, 40.7128, -74.0060)
        ]

        let placeData: [(name: String, location: String, icon: DayOneIcon, lat: Double, lon: Double)] = [
            ("Whole Foods Market", "Park City, Utah", .cart, 40.6520, -111.5070),
            ("Starbucks Coffee", "Salt Lake City", .food, 40.7649, -111.8920),
            ("Sundance Mountain Resort", "Provo, Utah", .skiing, 40.3939, -111.5869),
            ("Silver Lake Trail", "Park City, Utah", .hiking, 40.6580, -111.4950),
            ("Park City Library", "Park City, Utah", .books_filled, 40.6449, -111.5044),
            ("Life Time Fitness", "Sandy, Utah", .health, 40.5675, -111.8848),
            ("The Eating Establishment", "Park City, Utah", .food, 40.6465, -111.4978),
            ("Blue Lemon", "Salt Lake City", .food, 40.7589, -111.8883),
            ("City Creek Mall", "Salt Lake City", .cart, 40.7691, -111.8935),
            ("Liberty Park", "Salt Lake City", .location_navigate, 40.7425, -111.8733),
            ("Vivint Arena", "Salt Lake City", .calendar, 40.7683, -111.9011),
            ("Natural History Museum", "Salt Lake City", .bookmark, 40.7637, -111.8377),
            ("Red Butte Garden", "Salt Lake City", .location_navigate, 40.7757, -111.8153),
            ("The Leonardo", "Salt Lake City", .bookmark, 40.7650, -111.8967),
            ("REI Co-op", "Sandy, Utah", .hiking, 40.5650, -111.8900),
            ("Trader Joe's", "Salt Lake City", .cart, 40.7500, -111.8850)
        ]

        let homeData: [(subtitle: String, icon: DayOneIcon, lat: Double, lon: Double)] = [
            ("Mayne House", .map_pin_filled, 40.5200, -111.9500),
            ("Alpine Residence", .map_pin_filled, 40.4543, -111.7791),
            ("Mountain View", .map_pin_filled, 40.5850, -111.9200)
        ]

        let workData: [(subtitle: String, icon: DayOneIcon, lat: Double, lon: Double)] = [
            ("Day One Office", .pin_filled, 40.7500, -111.8800),
            ("Co-working Space", .pin_filled, 40.7600, -111.8900),
            ("Remote - Coffee Shop", .food, 40.7550, -111.8850)
        ]

        var visits: [Visit] = []
        let totalVisits = Int.random(in: 8...12)

        // Generate random times (chronological throughout the day)
        var currentHour = 7
        var currentMinute = Int.random(in: 0...59)

        // Determine type distribution
        let cityCount = Int.random(in: 0...2)      // 0-2 city visits
        let homeWorkCount = Int.random(in: 1...3)  // 1-3 home/work visits
        let placeCount = totalVisits - cityCount - homeWorkCount  // Rest are places

        // Generate city visits (some as standalone city visits, some with place names)
        for _ in 0..<cityCount {
            let city = cityData.randomElement()!
            let duration = [("2 hours", 120), ("3 hours", 180), ("4 hours", 240), ("5 hours", 300)].randomElement()!

            visits.append(Visit(
                type: .city,
                name: city.name,
                icon: city.icon,
                time: String(format: "%d:%02d %@", currentHour > 12 ? currentHour - 12 : currentHour, currentMinute, currentHour >= 12 ? "PM" : "AM"),
                duration: duration.0,
                latitude: city.lat,
                longitude: city.lon
            ))

            currentHour += duration.1 / 60
            currentMinute += duration.1 % 60
            if currentMinute >= 60 {
                currentHour += 1
                currentMinute -= 60
            }
        }

        // Generate place visits
        for _ in 0..<placeCount {
            let place = placeData.randomElement()!
            let durationMins = [20, 30, 45, 60, 90, 120].randomElement()!
            let durationStr = durationMins >= 60 ? "\(durationMins / 60) hour\(durationMins / 60 > 1 ? "s" : "")" : "\(durationMins) min"

            visits.append(Visit(
                type: .place,
                name: place.name,
                location: place.location,
                icon: place.icon,
                time: String(format: "%d:%02d %@", currentHour > 12 ? currentHour - 12 : currentHour, currentMinute, currentHour >= 12 ? "PM" : "AM"),
                duration: durationStr,
                latitude: place.lat,
                longitude: place.lon
            ))

            currentHour += durationMins / 60
            currentMinute += durationMins % 60
            if currentMinute >= 60 {
                currentHour += 1
                currentMinute -= 60
            }
            if currentHour >= 24 {
                currentHour = 23
                currentMinute = 30
            }
        }

        // Generate home/work visits
        for i in 0..<homeWorkCount {
            let isHome = i % 2 == 0
            let data = isHome ? homeData.randomElement()! : workData.randomElement()!
            let type: VisitType = isHome ? .home : .work
            let durationMins = isHome ? [60, 120, 180, 240].randomElement()! : [60, 120, 180, 240, 300, 360, 420, 480].randomElement()!
            let durationStr = "\(durationMins / 60) hour\(durationMins / 60 > 1 ? "s" : "")"

            visits.append(Visit(
                type: type,
                name: isHome ? "Home" : "Work",
                subtitle: data.subtitle,
                icon: data.icon,
                time: String(format: "%d:%02d %@", currentHour > 12 ? currentHour - 12 : currentHour, currentMinute, currentHour >= 12 ? "PM" : "AM"),
                duration: durationStr,
                latitude: data.lat,
                longitude: data.lon
            ))

            currentHour += durationMins / 60
            currentMinute += durationMins % 60
            if currentMinute >= 60 {
                currentHour += 1
                currentMinute -= 60
            }
            if currentHour >= 24 {
                currentHour = 23
                currentMinute = 30
            }
        }

        // Sort by priority: Cities first, then Places, then Home/Work
        return visits.sorted { v1, v2 in
            let priority1 = priorityForType(v1.type)
            let priority2 = priorityForType(v2.type)
            return priority1 < priority2
        }
    }

    private static func priorityForType(_ type: VisitType) -> Int {
        switch type {
        case .city: return 1
        case .place: return 2
        case .home, .work: return 3
        }
    }
}
