import Foundation

extension String {
    /// Extracts the first H1 heading from Markdown content.
    /// Returns the title without the `# ` prefix, or nil if no H1 found.
    func extractMarkdownTitle() -> String? {
        let lines = self.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("# ") {
                let title = String(trimmed.dropFirst(2))
                    .trimmingCharacters(in: .whitespaces)
                return title.isEmpty ? nil : title
            }
        }
        return nil
    }
}

/// Returns sample entry content that rotates across 5 different bodies based on
/// the day of the month, so navigating dates surfaces different sample titles.
func getSampleEntryContent(for date: Date) -> String {
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)

    switch day % 5 {
    case 0:
        return """
# Coffee Thoughts

This morning's coffee ritual felt especially meaningful. I sat by the window, watching the world wake up while the warm mug rested in my hands. There's something meditative about these quiet moments before the day truly begins.

I've been experimenting with different brewing methods lately, and today's pour-over turned out perfectly. The aroma filled the kitchen, and I found myself completely present in the moment, not thinking about the tasks ahead or dwelling on yesterday.

These small rituals anchor my days. Sometimes the most profound moments are the simplest ones—just me, a good cup of coffee, and the gentle morning light streaming through the window.
"""
    case 1:
        return """
# Weekend Adventures in the Mountains

We started our hike just after sunrise, the trail still damp with morning dew. The air was crisp and clean, filled with the scent of pine and wildflowers. Every step felt like a small adventure, winding through forests and across rocky outcrops.

Reaching the summit was incredible. The view stretched for miles—rolling peaks, valleys filled with mist, and the distant glimmer of a lake catching the sunlight. We sat there for a while, sharing snacks and taking it all in, feeling grateful for moments like these.

The descent was easier on the legs but harder on the knees. We laughed about how we'd feel tomorrow, but it was worth every step. There's something about being in nature that resets everything and reminds me what matters most.
"""
    case 2:
        return """
# A Perfect Fall Afternoon

The leaves were at their peak today—brilliant oranges, deep reds, and golden yellows painting the entire neighborhood. I decided to skip my usual routine and just wander, letting the autumn beauty guide my steps. The air had that perfect crispness that only fall can deliver.

I found myself at the old park bench under the oak tree, the same spot I've been coming to for years. Watching the leaves drift down one by one felt almost meditative. A family walked by with their kids jumping in leaf piles, their laughter echoing through the trees.

This is why fall is my favorite season. It's not just the colors or the weather—it's the feeling that everything is exactly as it should be, even as it all changes around us.
"""
    case 3:
        return """
# Finding Balance in Busy Days

The calendar was packed today, back-to-back meetings and endless tasks. But somewhere between the chaos, I found small pockets of peace—a five-minute walk, a deep breath before replying to that email, choosing to pause instead of rush.

I'm learning that balance isn't about perfectly dividing time between work and life. It's about being intentional with the moments I have, even the stressful ones. When I feel overwhelmed, I'm trying to remember that I can still choose how I respond.

Tonight, I closed my laptop at a reasonable hour. That felt like a small victory. Progress isn't always dramatic—sometimes it's just choosing yourself, even when everything else demands your attention.
"""
    case 4:
        return """
# Grateful for Small Moments of Peace Today

In the rush of daily life, I almost missed it—that quiet moment when everything felt still. It was brief, maybe just a minute or two, but it reminded me to slow down and notice what's good.

These small moments of peace are everywhere if I'm paying attention. The warmth of sunlight on my face, the smile from a stranger, the comfort of my favorite chair after a long day. They're easy to overlook when I'm focused on what's next.

Today, I'm choosing gratitude for these little things. They might seem insignificant, but together they create a life that feels full and meaningful.
"""
    default:
        return """
# Coffee Thoughts

This morning's coffee ritual felt especially meaningful. I sat by the window, watching the world wake up while the warm mug rested in my hands. There's something meditative about these quiet moments before the day truly begins.

I've been experimenting with different brewing methods lately, and today's pour-over turned out perfectly. The aroma filled the kitchen, and I found myself completely present in the moment, not thinking about the tasks ahead or dwelling on yesterday.

These small rituals anchor my days. Sometimes the most profound moments are the simplest ones—just me, a good cup of coffee, and the gentle morning light streaming through the window.
"""
    }
}
