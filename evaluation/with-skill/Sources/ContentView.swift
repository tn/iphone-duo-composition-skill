import SwiftUI

private let ink = Color(red: 0.20, green: 0.25, blue: 0.18)
private let paper = Color(red: 0.97, green: 0.95, blue: 0.89)
private let saffron = Color(red: 0.77, green: 0.33, blue: 0.13)

struct ContentView: View {
    @State private var recipe = Recipe.samples[0]
    @State private var step = 1
    @State private var checked: Set<Int> = []
    @State private var seconds = 480
    @State private var running = false
    @State private var choosingRecipe = false

    var body: some View {
        GeometryReader { geometry in
            if #available(iOS 27.1, *), geometry.size.width > 600 || !geometry.reservedRegions(kind: .division).isEmpty {
                ArrangementView {
                    GeometryReader { pane in
                        ScrollView {
                            VStack(alignment: .leading, spacing: pane.size.height < 430 ? 16 : 28) {
                                if pane.size.height < 430 {
                                    HStack {
                                        Text(recipe.title).font(.system(size: 19, weight: .medium, design: .serif))
                                        Spacer()
                                        Button { choosingRecipe = true } label: { Image(systemName: "book.closed") }
                                    }
                                } else { brand; introduction }
                                instruction(short: pane.size.height < 430)
                                stepControls
                            }.padding(pane.size.height < 430 ? 22 : 32)
                        }
                    }
                } secondary: {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 26) { timer; ingredients }.padding(28)
                    }.background(Color.white.opacity(0.45))
                }.arrangementViewStyle(.split)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        brand; introduction; instruction(short: false); stepControls; timer; ingredients
                    }.padding(24)
                }
            }
        }
        .background(paper).foregroundStyle(ink).tint(saffron).preferredColorScheme(.light)
        .sheet(isPresented: $choosingRecipe) { recipePicker }
        .task(id: running) {
            guard running else { return }
            while !Task.isCancelled && seconds > 0 {
                do { try await Task.sleep(for: .seconds(1)) } catch { return }
                guard !Task.isCancelled else { return }
                seconds -= 1
            }
            running = false
        }
    }

    private var brand: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill").foregroundStyle(saffron)
                Text("saffron").font(.system(size: 25, weight: .semibold, design: .serif))
            }
            Spacer()
            Button { choosingRecipe = true } label: {
                Label("Recipes", systemImage: "book.closed")
                    .font(.system(size: 14, weight: .medium)).padding(.horizontal, 14).padding(.vertical, 10)
                    .background(.white.opacity(0.65), in: Capsule())
            }.buttonStyle(.plain)
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ON THE MENU").font(.system(size: 10, weight: .bold)).tracking(2.5).foregroundStyle(saffron)
            Text(recipe.title).font(.system(size: 38, weight: .medium, design: .serif)).fixedSize(horizontal: false, vertical: true)
            Text(recipe.subtitle).font(.system(size: 15)).foregroundStyle(ink.opacity(0.65))
            HStack(spacing: 18) {
                Label("\(recipe.minutes) min", systemImage: "clock")
                Label("Serves \(recipe.servings)", systemImage: "person.2")
            }.font(.system(size: 12, weight: .medium)).foregroundStyle(ink.opacity(0.7))
        }
    }

    private func instruction(short: Bool) -> some View {
        VStack(alignment: .leading, spacing: short ? 12 : 20) {
            HStack {
                Text("LET’S COOK").tracking(2)
                Spacer()
                Text("0\(step + 1) / 0\(recipe.steps.count)")
            }.font(.system(size: 10, weight: .bold)).foregroundStyle(saffron)
            HStack(spacing: 5) {
                ForEach(recipe.steps.indices, id: \.self) { index in
                    Capsule().fill(index <= step ? saffron : ink.opacity(0.10)).frame(height: 3)
                }
            }
            Text(stepTitle).font(.system(size: short ? 27 : 31, weight: .medium, design: .serif))
            Text(recipe.steps[step]).font(.system(size: short ? 19 : 21)).lineSpacing(6).fixedSize(horizontal: false, vertical: true)
            if !short {
                Label("Take your time. Good things are cooking.", systemImage: "sparkle")
                    .font(.system(size: 12)).italic().foregroundStyle(ink.opacity(0.6)).padding(.top, 4)
            }
        }.padding(short ? 20 : 24).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.92, green: 0.90, blue: 0.81), in: RoundedRectangle(cornerRadius: 24))
    }

    private var stepTitle: String {
        if recipe.id == "lemon-pasta" { return ["Prepare your ingredients", "Cook the pasta", "Make it silky", "Finish & serve"][step] }
        return "Step \(step + 1)"
    }

    private var stepControls: some View {
        HStack {
            Button { step = max(0, step - 1) } label: {
                Label("Back", systemImage: "arrow.left").font(.system(size: 14, weight: .medium)).padding(15)
            }.disabled(step == 0).buttonStyle(.plain)
            Spacer()
            Button { step = min(recipe.steps.count - 1, step + 1) } label: {
                HStack(spacing: 18) {
                    Text(step == recipe.steps.count - 1 ? "Final step" : "Next step")
                    Image(systemName: "arrow.right")
                }.font(.system(size: 14, weight: .semibold)).padding(.horizontal, 22).padding(.vertical, 16)
                    .foregroundStyle(.white).background(ink, in: Capsule())
            }.buttonStyle(.plain).disabled(step == recipe.steps.count - 1)
        }
    }

    private var timer: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("KITCHEN TIMER", systemImage: "timer").font(.system(size: 10, weight: .bold)).tracking(1.5)
                Spacer()
                Text(running ? "RUNNING" : seconds == 0 ? "READY" : "PAUSED").font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(saffron)
            }
            HStack {
                Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                    .font(.system(size: 52, weight: .light, design: .rounded)).monospacedDigit()
                Spacer(minLength: 12)
                Button { running = false; seconds = 480 } label: {
                    Image(systemName: "arrow.counterclockwise").font(.system(size: 17)).frame(width: 35, height: 48)
                }.buttonStyle(.plain).accessibilityLabel("Reset timer")
                Button { if seconds == 0 { seconds = 480 }; running.toggle() } label: {
                    Image(systemName: running ? "pause.fill" : "play.fill").font(.system(size: 17)).frame(width: 50, height: 50)
                        .foregroundStyle(.white).background(saffron, in: Circle())
                }.buttonStyle(.plain).accessibilityLabel(running ? "Pause timer" : "Start timer")
            }
        }.padding(22).background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 22))
    }

    private var ingredients: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                Text("Your ingredients").font(.system(size: 25, weight: .medium, design: .serif))
                Spacer()
                Text("\(checked.count)/\(recipe.ingredients.count)").font(.system(size: 12)).foregroundStyle(ink.opacity(0.5))
            }
            Text("A little preparation, a lovely meal.").font(.system(size: 13)).foregroundStyle(ink.opacity(0.6))
            VStack(spacing: 0) {
                ForEach(recipe.ingredients.indices, id: \.self) { index in
                    Button {
                        if checked.contains(index) { checked.remove(index) } else { checked.insert(index) }
                    } label: {
                        HStack(spacing: 13) {
                            Image(systemName: checked.contains(index) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22, weight: .light)).foregroundStyle(checked.contains(index) ? saffron : ink.opacity(0.25))
                            Text(recipe.ingredients[index]).font(.system(size: 15)).strikethrough(checked.contains(index))
                                .foregroundStyle(ink.opacity(checked.contains(index) ? 0.4 : 1))
                            Spacer()
                        }.padding(.vertical, 15).contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    if index < recipe.ingredients.count - 1 { Divider() }
                }
            }
        }
    }

    private var recipePicker: some View {
        NavigationStack {
            List(Recipe.samples) { item in
                Button {
                    recipe = item; step = 0; checked = []; running = false; seconds = 480; choosingRecipe = false
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: item.symbol).font(.title2).foregroundStyle(saffron).frame(width: 32)
                        VStack(alignment: .leading, spacing: 7) {
                            Text(item.title).font(.system(size: 21, design: .serif)).foregroundStyle(ink)
                            Text("\(item.minutes) minutes · Serves \(item.servings)").font(.caption).foregroundStyle(.secondary)
                        }.padding(.vertical, 12)
                        Spacer()
                        if recipe.id == item.id { Image(systemName: "checkmark").foregroundStyle(saffron) }
                    }
                }
            }.scrollContentBackground(.hidden).background(paper).navigationTitle("Recipe book")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { choosingRecipe = false } } }
        }
    }
}
