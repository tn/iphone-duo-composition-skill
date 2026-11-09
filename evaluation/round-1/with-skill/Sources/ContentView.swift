import SwiftUI
import Combine

private let ink = Color(red: 0.17, green: 0.23, blue: 0.18)
private let cream = Color(red: 0.97, green: 0.96, blue: 0.91)
private let saffron = Color(red: 0.88, green: 0.54, blue: 0.18)

struct ContentView: View {
    @State private var recipe = Recipe.samples[0]
    @State private var step = 1
    @State private var checked: Set<Int> = []
    @State private var seconds = 480
    @State private var deadline: Date?
    @State private var showRecipes = false
    @State private var showIngredients = false
    private let tick = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            Group {
                if #available(iOS 27.1, *) {
                    let expanded = geometry.size.width >= 640 || !geometry.reservedRegions(kind: .division).isEmpty
                    if expanded {
                        ArrangementView {
                            cookingPane(compact: false)
                        } secondary: {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 30) {
                                    timerCard
                                    ingredients
                                }.padding(28)
                            }.background(Color.white.opacity(0.5))
                        }.arrangementViewStyle(.split)
                    } else {
                        cookingPane(compact: true)
                    }
                } else {
                    cookingPane(compact: true)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(cream.ignoresSafeArea())
        .foregroundStyle(ink)
        .tint(ink)
        .preferredColorScheme(.light)
        .sheet(isPresented: $showRecipes) { recipeSheet }
        .sheet(isPresented: $showIngredients) {
            NavigationStack {
                ScrollView { ingredients.padding(28) }
                    .background(cream)
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showIngredients = false } } }
            }.presentationDetents([.medium, .large])
        }
        .onReceive(tick) { now in
            guard let deadline else { return }
            seconds = max(0, Int(ceil(deadline.timeIntervalSince(now))))
            if seconds == 0 { self.deadline = nil }
        }
    }

    private func cookingPane(compact: Bool) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: compact ? 25 : 34) {
                HStack {
                    HStack(spacing: 7) {
                        Image(systemName: "leaf.fill").font(.system(size: 17))
                        Text("saffron").font(.system(size: 26, weight: .semibold, design: .serif))
                    }
                    Spacer()
                    Button { showRecipes = true } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "book.closed")
                            Text("Recipes")
                        }.font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 15).padding(.vertical, 11)
                            .background(.white.opacity(0.7), in: Capsule())
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("TONIGHT’S LITTLE RITUAL").font(.system(size: 10, weight: .bold)).tracking(2.2).foregroundStyle(ink.opacity(0.55))
                    Text(recipe.title).font(.system(size: compact ? 36 : 44, weight: .regular, design: .serif)).tracking(-1.4).fixedSize(horizontal: false, vertical: true)
                    Text(recipe.subtitle).font(.system(size: 14)).foregroundStyle(ink.opacity(0.65))
                    HStack(spacing: 19) {
                        Label("\(recipe.minutes) min", systemImage: "clock")
                        Label("Serves \(recipe.servings)", systemImage: "person.2")
                    }.font(.system(size: 12, weight: .medium)).foregroundStyle(ink.opacity(0.7)).padding(.top, 4)
                }
                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        Text("LET’S COOK").font(.system(size: 10, weight: .bold)).tracking(2)
                        Spacer()
                        Text("\(step + 1) / \(recipe.steps.count)").font(.system(size: 12, weight: .medium)).monospacedDigit()
                    }.foregroundStyle(ink.opacity(0.6))
                    HStack(spacing: 6) {
                        ForEach(recipe.steps.indices, id: \.self) { index in
                            Capsule().fill(index <= step ? saffron : ink.opacity(0.1)).frame(height: 4)
                        }
                    }
                    HStack(alignment: .top, spacing: 16) {
                        Text(String(format: "%02d", step + 1))
                            .font(.system(size: 38, weight: .regular, design: .serif)).foregroundStyle(saffron)
                        VStack(alignment: .leading, spacing: 12) {
                            Text(stepTitle).font(.system(size: compact ? 24 : 30, weight: .regular, design: .serif))
                            Text(recipe.steps[step]).font(.system(size: compact ? 17 : 22)).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    HStack(spacing: 12) {
                        Button { step = max(0, step - 1) } label: {
                            Image(systemName: "arrow.left").frame(width: 48, height: 48)
                        }.background(ink.opacity(0.06), in: Circle()).disabled(step == 0).opacity(step == 0 ? 0.3 : 1)
                        Button { step = min(recipe.steps.count - 1, step + 1) } label: {
                            HStack {
                                Text(step == recipe.steps.count - 1 ? "Ready to serve" : "Next step")
                                Spacer()
                                Image(systemName: step == recipe.steps.count - 1 ? "checkmark" : "arrow.right")
                            }.font(.system(size: 14, weight: .semibold)).padding(.horizontal, 20).frame(height: 48)
                        }.foregroundStyle(.white).background(ink, in: Capsule()).disabled(step == recipe.steps.count - 1)
                    }.padding(.top, 4)
                }.padding(compact ? 22 : 28).background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 26))
                if compact {
                    timerCard
                    Button { showIngredients = true } label: {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Ingredients")
                            Spacer()
                            Text("\(checked.count) / \(recipe.ingredients.count)").foregroundStyle(ink.opacity(0.5))
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                        }.font(.system(size: 15, weight: .medium)).padding(.vertical, 8)
                    }
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkle").foregroundStyle(saffron)
                        Text("Good food. A little attention.").font(.system(size: 14, weight: .regular, design: .serif)).italic()
                    }.foregroundStyle(ink.opacity(0.55)).padding(.leading, 4)
                }
            }.padding(compact ? 24 : 32)
        }
    }

    private var stepTitle: String {
        if recipe.id == "lemon-pasta" { return ["A little preparation", "Cook the pasta", "Make it silky", "The finishing touch"][step] }
        if recipe.id == "tomato-toast" { return ["Golden & crisp", "A touch of garlic", "Pile on summer"][step] }
        return ["Prepare your ingredients", "Build the flavour", "Low and slow", "Rest & finish"][step]
    }

    private var timerCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("KITCHEN TIMER", systemImage: "timer").font(.system(size: 10, weight: .bold)).tracking(1.4)
                Spacer()
                Text(deadline == nil ? (seconds == 0 ? "DONE" : "PAUSED") : "RUNNING")
                    .font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(ink.opacity(0.55))
            }
            HStack(alignment: .center) {
                Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                    .font(.system(size: 49, weight: .light, design: .rounded)).monospacedDigit().tracking(-2)
                Spacer(minLength: 12)
                Button {
                    if deadline != nil { deadline = nil }
                    else { if seconds == 0 { seconds = 480 }; deadline = Date().addingTimeInterval(TimeInterval(seconds)) }
                } label: {
                    Image(systemName: deadline == nil ? "play.fill" : "pause.fill")
                        .font(.system(size: 18)).frame(width: 50, height: 50)
                }.foregroundStyle(.white).background(ink, in: Circle())
                Button { deadline = nil; seconds = 480 } label: {
                    Image(systemName: "arrow.counterclockwise").font(.system(size: 18)).frame(width: 34, height: 50)
                }
            }
        }.padding(22).background(Color(red: 0.94, green: 0.83, blue: 0.55), in: RoundedRectangle(cornerRadius: 24))
    }

    private var ingredients: some View {
        VStack(alignment: .leading, spacing: 19) {
            HStack(alignment: .firstTextBaseline) {
                Text("At the ready").font(.system(size: 29, weight: .regular, design: .serif))
                Spacer()
                Text("\(checked.count)/\(recipe.ingredients.count)").font(.system(size: 12, weight: .medium)).foregroundStyle(ink.opacity(0.5))
            }
            Text("INGREDIENTS · SERVES \(recipe.servings)").font(.system(size: 10, weight: .bold)).tracking(1.5).foregroundStyle(ink.opacity(0.5))
            VStack(spacing: 0) {
                ForEach(recipe.ingredients.indices, id: \.self) { index in
                    Button {
                        if checked.contains(index) { checked.remove(index) } else { checked.insert(index) }
                    } label: {
                        HStack(spacing: 13) {
                            Image(systemName: checked.contains(index) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22, weight: .light)).foregroundStyle(checked.contains(index) ? ink : ink.opacity(0.3))
                            Text(recipe.ingredients[index]).font(.system(size: 16)).strikethrough(checked.contains(index)).foregroundStyle(ink.opacity(checked.contains(index) ? 0.4 : 1))
                            Spacer(minLength: 0)
                        }.padding(.vertical, 15)
                    }.buttonStyle(.plain)
                    if index < recipe.ingredients.count - 1 { Divider().overlay(ink.opacity(0.04)) }
                }
            }
        }
    }

    private var recipeSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Something delicious.").font(.system(size: 34, design: .serif)).padding(.bottom, 8)
                    ForEach(Recipe.samples) { item in
                        Button {
                            recipe = item; step = 0; checked = []; seconds = 480; deadline = nil; showRecipes = false
                        } label: {
                            HStack(spacing: 18) {
                                Image(systemName: item.symbol).font(.system(size: 27)).foregroundStyle(saffron).frame(width: 48)
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(item.title).font(.system(size: 22, design: .serif))
                                    Text("\(item.minutes) minutes · Serves \(item.servings)").font(.system(size: 12)).foregroundStyle(ink.opacity(0.6))
                                }
                                Spacer()
                                Image(systemName: recipe.id == item.id ? "checkmark.circle.fill" : "arrow.up.right")
                            }.padding(20).background(.white, in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain)
                    }
                }.padding(24)
            }.background(cream).foregroundStyle(ink)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showRecipes = false } } }
        }
    }
}
