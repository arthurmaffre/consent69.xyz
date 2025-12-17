//
//  ContractsView.swift
//  SwiftUIStarterKitApp
//
//  Created by [Ton Nom] on 14/11/2025.
//  Copyright © 2025 Consent69. All rights reserved.
//

import SwiftUI

// Modèles pour les contrats de consent (fun & light : humour sur le dating safe via Ergo)
struct ConsentContract: Identifiable {
    let id = UUID()
    let title: String
    let partner: String // Pseudo anonyme pour privacy
    let status: ConsentStatus
    let vibe: String // Niveau : Chill, Fun, Epic
    let qrData: String // Pour signer/revoker via scan Ergo
    var isActive: Bool = true
    static let disclaimer: String = "Tout est fun, consensuel et revocable en un clin d'œil. Pas de drama, juste des vibes positives !"
}

enum ConsentStatus: String, CaseIterable {
    case negotiating = "En flirt mode"
    case signed = "Deal scanné !"
    case revocable = "Revoke facile"
    case completed = "Mission fun accomplie"
    
    var icon: String {
        switch self {
        case .negotiating: return "sparkles"
        case .signed: return "hand.thumbsup"
        case .revocable: return "arrow.counterclockwise"
        case .completed: return "trophy"
        }
    }
    var color: Color {
        switch self {
        case .negotiating: return .yellow
        case .signed: return .green
        case .revocable: return .blue
        case .completed: return .orange
        }
    }
}

// Types de consents fun (thème dating humoristique : safe, witty, sans choc)
struct ConsentType: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let description: String // Humour léger : puns, auto-dérision, focus sur fun safe
    let duration: String
    let bondRequired: Bool // "Caution" pour les vibes plus engagées
    let maxPartners: Int // 1-to-1 vs multi (mais chill)
}

// Mocks fun pour tester (légers, drôles : détails witty, anonymes, safe)
let mockActiveConsents: [ConsentContract] = [
    ConsentContract(title: "Date Café Rigolade", partner: "Alex 😄", status: .signed, vibe: "Chill", qrData: "consent:cafe-fun:2025-11-14:revocable-easy"),
    ConsentContract(title: "Soirée Ciné & Rires", partner: "Jordan 🎥", status: .revocable, vibe: "Fun", qrData: "consent:cine-bond:2025-11-14:popcorn-qr"),
    ConsentContract(title: "Balade Poly Amicale", partner: "Sam 👯", status: .negotiating, vibe: "Epic", qrData: "consent:poly-walk:2025-11-14:group-hug")
]

let mockConsentTypes: [ConsentType] = [
    ConsentType(title: "1-to-1 Café Chill", icon: "cup.and.saucer", description: "Consent pour un café où les blagues fusent plus vite que les cœurs qui s'emballent. Revocable si le latte est trop amer – safe et hilarant !", duration: "1h", bondRequired: false, maxPartners: 2),
    ConsentType(title: "1-to-1 Bond Ciné", icon: "popcorn", description: "Avec 'caution' Ergo pour le popcorn : si le film est nul, le destructeur invite au suivant. Parfait pour des dates où on rit des twists ratés.", duration: "2h", bondRequired: true, maxPartners: 2),
    ConsentType(title: "Temp Poly Balade", icon: "figure.walk", description: "Consent groupé pour une promenade où les stories embarrassantes volent bas. Auto-expire si quelqu'un spoile le sunset – fun sans pression.", duration: "1 soir", bondRequired: false, maxPartners: 4),
    ConsentType(title: "4-to-4 Soirée Jeux", icon: "gamecontroller", description: "Équipe vs Équipe pour une game night : consents croisés, bonds pour les perdants qui trichent. Focus sur les fous rires, pas les scores.", duration: "Événement", bondRequired: true, maxPartners: 8),
    ConsentType(title: "Escrow Rires Payés", icon: "dollarsign.circle", description: "Fonds libérés par milestone (ex. après une blague réussie). Pour des hangs ongoing où l'humour est la vraie monnaie.", duration: "Ongoing", bondRequired: true, maxPartners: 4),
    ConsentType(title: "Multi-Revocable Fun", icon: "figure.walk.motion.trianglebadge.exclamationmark", description: "Réseau de consents drôles : stand-up virtuel, memes partagés, revocable si la vanne tombe à plat. Idéal pour squads safe et silly.", duration: "Flexible", bondRequired: false, maxPartners: 10)
]

struct ContractsView: View {
    @State private var selectedType: ConsentType?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24, pinnedViews: [.sectionHeaders]) {
                    // Section 1: Consents en cours (fun, witty détails)
                    Section(header: headerView(title: "Tes Consents Fun", subtitle: "Vibes actives – revocables en un rire")) {
                        if mockActiveConsents.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(mockActiveConsents) { consent in
                                NavigationLink(destination: ConsentDetailView(consent: consent)) {
                                    ConsentCardView(consent: consent)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Section 2: Types de Consents (descriptions witty, humoristiques)
                    Section(header: headerView(title: "Nouveaux Modèles", subtitle: "Choisis ton fun, scanne et ris")) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(mockConsentTypes) { type in
                                ConsentTypeCardView(type: type)
                                    .onTapGesture {
                                        selectedType = type
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Consents Fun")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedType) { type in
                ConsentCreatorSheet(type: type)
            }
            .refreshable {
                await refreshConsents()
            }
        }
    }
    
    private func headerView(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("Aucun consent fun")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.primary)
                
                Text("Lance la machine à rires : crée ton premier QR pour des dates safe et délirantes.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            Button("Découvrir Modèles") {
                // Action
            }
            .buttonStyle(.borderedProminent)
            .tint(.yellow)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private func refreshConsents() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        print("Consents refreshed from Ergo – let's laugh!")
    }
}

// Card consent : Fun, avec vibe légère
struct ConsentCardView: View {
    let consent: ConsentContract
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: consent.status.icon)
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(consent.status.color)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(consent.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(consent.partner)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(consent.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(consent.status.color.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text(consent.vibe)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.yellow)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// Card type : Descriptions drôles, safe
struct ConsentTypeCardView: View {
    let type: ConsentType
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.system(size: 32))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .frame(width: 64, height: 64)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
            
            Text(type.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Text(type.description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Durée")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                    Text(type.duration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if type.bondRequired {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(type.maxPartners)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("partners")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

// Sheet créateur : Tease fun
struct ConsentCreatorSheet: View {
    let type: ConsentType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: type.icon)
                    .font(.system(size: 80))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor)
                
                VStack(spacing: 8) {
                    Text(type.title)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text(type.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    Text(ConsentContract.disclaimer)
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .italic()
                }
                .padding(.horizontal)
                
                Button("Lancer le QR Fun") {
                    // Vers scanner
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.yellow)
                
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Annuler") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// Détail consent (immersif mais light)
struct ConsentDetailView: View {
    let consent: ConsentContract
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ConsentCardView(consent: consent)
                    .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Détails Fun")
                        .font(.title2.weight(.semibold))
                    
                    HStack {
                        Text("Partner")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(consent.partner)
                            .font(.body)
                    }
                    
                    HStack {
                        Text("Vibe")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(consent.vibe)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.yellow)
                    }
                    
                    Text(ConsentContract.disclaimer)
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    Button("Revoker via QR") {
                        // Action
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
        .navigationTitle(consent.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview
#Preview {
    ContractsView()
}
