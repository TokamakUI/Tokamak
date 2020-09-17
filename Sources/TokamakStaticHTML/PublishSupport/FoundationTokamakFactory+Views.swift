#if canImport(Publish)
import Foundation
import Publish

extension FoundationTokamakFactory {
  struct ItemList: View {
    let items: [Item<Site>]
    let site: Site

    var body: some View {
      VStack(alignment: .leading) {
        ForEach(items) { item in
          VStack(alignment: .leading) {
            Link(destination: URL(string: item.path.absoluteString)!) {
              Text(item.title)
                .font(.headline)
                .underline()
            }
            TagList(item: item, site: site)
              .padding(.vertical)
            Text(item.description)
              .font(.caption)
          }
          .padding(20)
          .background(Color(0xEEEEEE))
          .cornerRadius(20)
        }
      }
    }
  }

  struct TagList: View {
    let item: Item<Site>
    let site: Site

    var body: some View {
      HStack(spacing: 5) {
        ForEach(item.tags) { tag in
          Tag(tag: tag, site: site)
        }
      }
    }
  }

  struct Header: View {
    let context: PublishingContext<Site>
    let selectedSection: Site.SectionID?

    let sectionIDs = Site.SectionID.allCases

    var body: some View {
      VStack {
        Link(
          context.site.name,
          destination: URL(string: "/", relativeTo: context.site.url)!
        )
        .font(.system(size: 18, weight: .bold))
        .padding(.bottom)
        if sectionIDs.count > 1 {
          HStack(spacing: 16) {
            ForEach(Array(sectionIDs), id: \.self) { section in
              Link(destination: URL(
                string: context.sections[section].path
                  .absoluteString
              )!) {
                Text(context.sections[section].title)
                  .underline(section == selectedSection, color: .primary)
              }
            }
          }
        }
        // FIXME: Could not cast value of type 'Swift.Optional<TokamakCore.HStack<TokamakCore.ForEach<Swift.Array<PublishTokamak.PublishTokamak.SectionID>, PublishTokamak.PublishTokamak.SectionID, TokamakCore.ModifiedContent<TokamakCore.ModifiedContent<TokamakCore.ModifiedContent<TokamakCore.Link<TokamakCore.Text>, TokamakCore._PaddingLayout>, TokamakCore._BackgroundModifier<TokamakCore.Color>>, TokamakCore._PaddingLayout>>>>' (0x7ffac7021410) to 'TokamakCore.ViewDeferredToRenderer' (0x7ffac7021710).
        else { EmptyView() }
      }
      .padding(.horizontal, 40)
      .padding(.vertical, 30)
      .background(Color(0xEEEEEE))
      .frame(minWidth: 0, maxWidth: .infinity)
    }
  }

  struct Footer: View {
    let site: Site
    var body: some View {
      VStack {
        HStack {
          Text("Generated using")
            .padding(.trailing)
          Link(destination: URL(string: "https://github.com/johnsundell/publish")!) {
            Text("Publish")
              .underline()
          }
          Text("and")
            .padding(.horizontal)
          Link(destination: URL(string: "https://github.com/TokamakUI/Tokamak")!) {
            Text("Tokamak")
              .underline()
          }
        }
        HStack {
          Link("RSS Feed", destination: URL(string: "/feed.rss", relativeTo: site.url)!)
        }
      }
      .foregroundColor(Color(0x8A8A8A))
    }
  }

  struct Tag: View {
    let tag: Publish.Tag
    let site: Site

    var body: some View {
      Link(destination: URL(string: site.path(for: tag).absoluteString)!) {
        Text(tag.string)
          .padding(.horizontal, 6)
          .padding(.vertical, 4)
          .background(Color.black)
          .foregroundColor(.white)
          .cornerRadius(5)
      }
    }
  }
}
#endif // canImport(Publish)
