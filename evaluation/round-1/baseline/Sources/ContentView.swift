import SwiftUI
import UIKit

struct ContentView: View {
    @State private var recipe = Recipe.samples[0]
    @State private var step = 1
    @State private var checked: Set<Int> = []
    @State private var remaining = 480
    @State private var running = false
    @State private var folded = false
    @State private var showRecipes = false
    @State private var showIngredients = false
    private let cream = Color(red: 0.97, green: 0.95, blue: 0.89)
    private let ink = Color(red: 0.18, green: 0.24, blue: 0.18)
    private let accent = Color(red: 0.77, green: 0.29, blue: 0.12)

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width > 620
            VStack(spacing: 0) {
                header
                if folded && wide {
                    VStack(spacing: 0) {
                        ScrollView { instruction.padding(28) }.frame(maxHeight: .infinity)
                        Rectangle().fill(ink.opacity(0.12)).frame(height: 24)
                        HStack(alignment: .top, spacing: 32) {
                            ScrollView { ingredients }.frame(maxWidth: .infinity)
                            VStack(spacing: 24) { timer; navigation }.frame(maxWidth: .infinity)
                        }.padding(28).frame(maxHeight: .infinity)
                    }
                } else if wide {
                    HStack(alignment: .top, spacing: 0) {
                        ScrollView { VStack(alignment: .leading, spacing: 32) { recipeHeading; ingredients }.padding(30) }
                            .frame(maxWidth: .infinity)
                        Rectangle().fill(ink.opacity(0.13)).frame(width: 1).padding(.vertical, 28)
                        ScrollView { VStack(spacing: 26) { instruction; timer; navigation }.padding(30) }
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 25) {
                            recipeHeading
                            Button { showIngredients = true } label: {
                                HStack { Image(systemName: "checklist"); Text("Ingredients"); Spacer(); Text("\(checked.count) of \(recipe.ingredients.count)").foregroundStyle(ink.opacity(0.6)); Image(systemName: "chevron.right") }
                                    .font(.subheadline.weight(.medium)).padding(16).background(.white.opacity(0.65), in: RoundedRectangle(cornerRadius: 16))
                            }
                            instruction
                            timer
                            navigation
                        }.padding(24)
                    }
                }
            }
            .background(cream).foregroundStyle(ink)
            .background { if #available(iOS 27.1, *) { HingeObserver(folded: $folded).frame(width: 0, height: 0) } }
        }
        .tint(accent)
        .preferredColorScheme(.light)
        .sheet(isPresented: $showRecipes) { recipePicker }
        .sheet(isPresented: $showIngredients) {
            NavigationStack { ScrollView { ingredients.padding(24) }.background(cream).navigationTitle("Ingredients").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showIngredients = false } } } }
                .presentationDetents([.medium, .large])
        }
        .task(id: running) {
            guard running else { return }
            while !Task.isCancelled && remaining > 0 {
                do { try await Task.sleep(for: .seconds(1)) } catch { return }
                remaining -= 1
            }
            if remaining == 0 { running = false }
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) { Image(systemName: "sparkle").foregroundStyle(accent); Text("saffron").font(.system(size: 27, weight: .semibold, design: .serif)) }
            Spacer()
            Button { showRecipes = true } label: { Label("Recipes", systemImage: "square.grid.2x2").font(.subheadline.weight(.medium)).padding(.horizontal, 16).padding(.vertical, 11).background(.white.opacity(0.7), in: Capsule()) }
        }.padding(.horizontal, 26).padding(.vertical, 15)
        .overlay(alignment: .bottom) { Rectangle().fill(ink.opacity(0.12)).frame(height: 1) }
    }

    private var recipeHeading: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 7) { Circle().fill(accent).frame(width: 6, height: 6); Text("TONIGHT’S LITTLE JOY").font(.system(size: 10, weight: .bold)).tracking(2) }.foregroundStyle(accent)
            Text(recipe.title).font(.system(size: 38, weight: .regular, design: .serif)).fixedSize(horizontal: false, vertical: true)
            Text(recipe.subtitle).font(.subheadline).foregroundStyle(ink.opacity(0.65))
            HStack(spacing: 20) { Label("\(recipe.minutes) min", systemImage: "clock"); Label("Serves \(recipe.servings)", systemImage: "person.2") }.font(.caption.weight(.medium)).foregroundStyle(ink.opacity(0.7))
            ZStack {
                RoundedRectangle(cornerRadius: 25).fill(Color(red: 0.89, green: 0.88, blue: 0.72))
                Circle().fill(cream.opacity(0.7)).frame(width: 115, height: 115)
                Circle().stroke(ink.opacity(0.1), lineWidth: 1).frame(width: 97, height: 97)
                Image(systemName: recipe.symbol).font(.system(size: 53, weight: .ultraLight)).rotationEffect(.degrees(-25)).foregroundStyle(ink)
                VStack { HStack { Spacer(); Text("FRESH & SIMPLE").font(.system(size: 8, weight: .semibold)).tracking(2) }; Spacer(); HStack { Text("The everyday collection").font(.system(size: 12, design: .serif)).italic(); Spacer(); Image(systemName: "fork.knife").font(.caption) } }.padding(18)
            }.frame(height: 155)
        }
    }

    private var ingredients: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { Text("On the counter").font(.system(size: 25, design: .serif)); Spacer(); Text("\(checked.count)/\(recipe.ingredients.count)").font(.caption.monospacedDigit()).foregroundStyle(ink.opacity(0.5)) }.padding(.bottom, 12)
            ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
                Button { if checked.contains(index) { checked.remove(index) } else { checked.insert(index) } } label: {
                    HStack(spacing: 13) {
                        Image(systemName: checked.contains(index) ? "checkmark.circle.fill" : "circle").font(.system(size: 22, weight: .light)).foregroundStyle(checked.contains(index) ? accent : ink.opacity(0.3))
                        Text(ingredient).font(.system(size: 15)).strikethrough(checked.contains(index)).foregroundStyle(ink.opacity(checked.contains(index) ? 0.4 : 0.9))
                        Spacer(minLength: 0)
                    }.padding(.vertical, 10)
                }.buttonStyle(.plain)
                if index < recipe.ingredients.count - 1 { Rectangle().fill(ink.opacity(0.08)).frame(height: 1) }
            }
        }
    }

    private var instruction: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack { Text("LET’S COOK").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(accent); Spacer(); Text("STEP \(step + 1) OF \(recipe.steps.count)").font(.system(size: 10, weight: .semibold)).tracking(1).foregroundStyle(ink.opacity(0.5)) }
            HStack(spacing: 6) { ForEach(recipe.steps.indices, id: \.self) { index in Capsule().fill(index <= step ? accent : ink.opacity(0.12)).frame(height: 3) } }
            Text(stepTitle).font(.system(size: 33, weight: .regular, design: .serif))
            Text(recipe.steps[step]).font(.system(size: 20, weight: .regular)).lineSpacing(7).fixedSize(horizontal: false, vertical: true)
            if step + 1 < recipe.steps.count {
                HStack(alignment: .top, spacing: 10) { Image(systemName: "arrow.turn.down.right"); Text("Up next · \(nextTitle)").lineLimit(2) }.font(.caption).foregroundStyle(ink.opacity(0.5)).padding(.top, 4)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stepTitle: String {
        if recipe.id == "lemon-pasta" { return ["A little preparation", "Cook the pasta", "Make it silky", "The finishing touch"][step] }
        return "\(step == 0 ? "Get ready" : step == recipe.steps.count - 1 ? "Bring it together" : "Keep it cooking")"
    }
    private var nextTitle: String { recipe.steps[min(step + 1, recipe.steps.count - 1)] }

    private var timer: some View {
        VStack(spacing: 15) {
            HStack { Label("PASTA TIMER", systemImage: "timer").font(.system(size: 10, weight: .semibold)).tracking(1.5); Spacer(); Text(running ? "RUNNING" : remaining == 0 ? "READY" : "PAUSED").font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(.white.opacity(0.55)) }
            Text(String(format: "%02d:%02d", remaining / 60, remaining % 60)).font(.system(size: 64, weight: .light, design: .rounded)).monospacedDigit().tracking(-2)
            HStack(spacing: 12) {
                Button { if remaining == 0 { remaining = 480 }; running.toggle() } label: { Label(running ? "Pause timer" : "Start timer", systemImage: running ? "pause.fill" : "play.fill").font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 14).background(cream, in: Capsule()).foregroundStyle(ink) }
                Button { running = false; remaining = 480 } label: { Image(systemName: "arrow.counterclockwise").frame(width: 46, height: 46).background(.white.opacity(0.12), in: Circle()) }.accessibilityLabel("Reset timer")
            }
        }.padding(23).foregroundStyle(cream).background(ink, in: RoundedRectangle(cornerRadius: 26))
    }

    private var navigation: some View {
        HStack {
            Button { step -= 1 } label: { Image(systemName: "arrow.left").frame(width: 48, height: 48).background(ink.opacity(0.06), in: Circle()) }.disabled(step == 0)
            Spacer()
            Button { if step < recipe.steps.count - 1 { step += 1 } else { showRecipes = true } } label: { HStack(spacing: 18) { Text(step == recipe.steps.count - 1 ? "Finish cooking" : "Next step"); Image(systemName: "arrow.right") }.font(.subheadline.weight(.semibold)).padding(.horizontal, 25).padding(.vertical, 16).background(accent, in: Capsule()).foregroundStyle(.white) }
        }
    }

    private var recipePicker: some View {
        NavigationStack {
            List(Recipe.samples) { item in
                Button { recipe = item; step = 0; checked = []; running = false; remaining = 480; showRecipes = false } label: {
                    HStack(spacing: 18) { Image(systemName: item.symbol).font(.title2).frame(width: 48, height: 60).foregroundStyle(accent); VStack(alignment: .leading, spacing: 5) { Text(item.title).font(.headline); Text("\(item.minutes) minutes · Serves \(item.servings)").font(.caption).foregroundStyle(.secondary) }; Spacer(); if recipe.id == item.id { Image(systemName: "checkmark") } }.padding(.vertical, 10)
                }.foregroundStyle(ink)
            }.navigationTitle("Your recipe box").toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showRecipes = false } } }
        }
    }
}

@available(iOS 27.1, *)
private struct HingeObserver: UIViewRepresentable {
    @Binding var folded: Bool
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.addInteraction(UIHingeInteraction { _, update in
            let isFolded = update.hinge?.status == .partiallyOpen
            DispatchQueue.main.async { folded = isFolded }
        })
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
