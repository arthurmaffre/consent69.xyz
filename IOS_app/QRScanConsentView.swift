//
//  QRScanConsentView.swift
//  SwiftUIStarterKitApp
//
//  Created by [Ton Nom] on 14/11/2025.
//  Copyright © 2025 [Ton Entreprise]. All rights reserved.
//

import SwiftUI
import AVFoundation // Pour le scanner QR

// Modèle simple pour les données de consent (tu peux l'adapter à tes mocks)
struct ConsentItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let qrData: String // Données encodées dans le QR pour ce consent
    var isScanned: Bool = false
}

// Mock data pour tester (remplace par ActivitiesMockStore si besoin)
let mockConsents: [ConsentItem] = [
    ConsentItem(title: "Consentement Contrat A", description: "Validation via QR pour contrat standard.", qrData: "consent:A:2025-11-14"),
    ConsentItem(title: "Consentement Contrat B", description: "Validation via QR pour contrat premium.", qrData: "consent:B:2025-11-14")
]

// Vue principale pour le scan QR de consent
struct QRScanConsentView: View {
    @State private var scannedConsents: [ConsentItem] = mockConsents // État pour les consents scannés
    @State private var isPaused = false // Scanner en pause ou actif
    @State private var showMyQRSheet = false // Sheet pour afficher mon QR code
    @State private var scannedCode: String = "" // Résultat du scan
    @State private var torchIsOn = false // Lampe torche
    @State private var scannerError: String? // Pour afficher erreurs (ex. simu)

    // Permissions caméra
    @State private var cameraPermission: AVAuthorizationStatus = .notDetermined
    @State private var hasCheckedPermission = false // Pour éviter les checks multiples

    // Scanner actif = permission OK + pas d'erreur + pas en pause
    private var isScannerActive: Bool {
        cameraPermission == .authorized && scannerError == nil && !isPaused
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview en fond (plein écran, toujours visible si autorisé)
                // Ajout d'un check hasCheckedPermission pour éviter le pré-chargement
                if cameraPermission == .authorized && scannerError == nil && hasCheckedPermission {
                    QRScannerView(
                        scannedCode: $scannedCode,
                        torchIsOn: $torchIsOn,
                        isPaused: $isPaused
                    )
                    .ignoresSafeArea()
                    .onChange(of: scannedCode) { _, newCode in
                        handleScanResult(newCode)
                    }
                } else {
                    // Fond dégradé si pas de caméra
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }

                // Overlay avec les contrôles
                VStack(spacing: 0) {
                    // Header semi-transparent avec instructions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scanner un QR Code")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Text("Pointez la caméra vers le QR pour valider un consentement.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.black.opacity(isScannerActive ? 0.5 : 0))

                    // Erreur si scanner indispo (ex. simu ou permissions)
                    if let error = scannerError {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundStyle(.orange)
                            Text(error)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            // Bouton pour aller aux réglages si permission refusée
                            if cameraPermission == .denied {
                                Button("Ouvrir les Réglages") {
                                    openAppSettings()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
                            }
                        }
                        .padding()
                        .background(.yellow.opacity(0.1))
                        .cornerRadius(16)
                        .padding()
                        Spacer()
                    } else if cameraPermission == .notDetermined && hasCheckedPermission {
                        // En attente de permission
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Demande d'accès à la caméra...")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    } else {
                        Spacer()
                    }

                    // Zone du bas avec liste des scans et bouton pause
                    VStack(spacing: 16) {
                        // Liste des consents scannés
                        if !scannedConsents.filter({ $0.isScanned }).isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(scannedConsents.filter { $0.isScanned }) { consent in
                                        HStack(spacing: 8) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                            Text(consent.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.white)
                                        .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Bouton Pause/Reprendre (si caméra autorisée)
                        if cameraPermission == .authorized && scannerError == nil {
                            Button(action: { isPaused.toggle() }) {
                                HStack {
                                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                    Text(isPaused ? "Reprendre le scan" : "Mettre en pause")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isPaused ? Color.green : Color.blue.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                    .padding(.vertical)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(isScannerActive ? 0.7 : 0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .navigationTitle("Scan Consent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                // Bouton haut gauche : Mon QR Code
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showMyQRSheet = true }) {
                        Image(systemName: "qrcode")
                            .font(.title2)
                            .foregroundStyle(isScannerActive ? .white : .blue)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                    .accessibilityLabel("Afficher mon code QR")
                }

                // Bouton torche (visible si scanner actif)
                ToolbarItem(placement: .topBarTrailing) {
                    if cameraPermission == .authorized && scannerError == nil {
                        Button(action: { torchIsOn.toggle() }) {
                            Image(systemName: torchIsOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .foregroundStyle(torchIsOn ? .yellow : .white)
                                .shadow(color: .black.opacity(0.3), radius: 2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showMyQRSheet) {
                MyQRCodeView(qrData: "my-consent:2025-11-14:user-id") // Remplace par tes données réelles
            }
            .onAppear {
                checkCameraAndDevice()
            }
        }
        .accentColor(.blue) // Style Apple pour les accents
    }

    // Ouvre les réglages de l'app
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // Fonction pour gérer le résultat du scan
    private func handleScanResult(_ code: String) {
        // Cherche si le code match un consent
        if let matchingConsent = mockConsents.first(where: { $0.qrData == code }) {
            // Marque comme scanné (tu peux ajouter à un store global ici)
            if let index = scannedConsents.firstIndex(where: { $0.id == matchingConsent.id }) {
                scannedConsents[index].isScanned = true
            }
            // Feedback haptique Apple-style
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            // Pause le scanner après scan (optionnel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isPaused = true
            }
        } else {
            // Pas de match : alerte
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        scannedCode = "" // Reset pour prochain scan
    }
    
    // Vérifie les permissions ET la dispo device - Lance automatiquement le scanner
    @MainActor
    private func checkCameraAndDevice() {
        hasCheckedPermission = true

        // Check si on est sur simu (UIDevice.isSimulator)
        #if targetEnvironment(simulator)
        scannerError = "Scanner indisponible sur simulateur. Utilisez un device physique."
        print("DEBUG: Running on simulator - QR scanner disabled.")
        #else
        // Check le statut actuel des permissions
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch currentStatus {
        case .authorized:
            // Déjà autorisé -> on lance directement le scanner
            cameraPermission = .authorized
            isPaused = false // Scanner actif automatiquement
            print("DEBUG: Camera already authorized - Scanner starting automatically.")

        case .notDetermined:
            // Jamais demandé -> on demande la permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraPermission = granted ? .authorized : .denied
                    if granted {
                        self.isPaused = false // Scanner actif automatiquement
                        print("DEBUG: Camera permission granted - Scanner starting automatically.")
                    } else {
                        self.scannerError = "Accès caméra refusé. Activez dans Réglages > App."
                        print("DEBUG: Camera permission denied.")
                    }
                }
            }

        case .denied, .restricted:
            // Refusé ou restreint
            cameraPermission = .denied
            scannerError = "Accès caméra refusé. Activez dans Réglages > App."
            print("DEBUG: Camera permission denied or restricted.")

        @unknown default:
            break
        }
        #endif
    }
}

// Vue pour le scanner QR (composant réutilisable) - Avec support pause
struct QRScannerView: UIViewRepresentable {
    @Binding var scannedCode: String
    @Binding var torchIsOn: Bool
    @Binding var isPaused: Bool

    func makeUIView(context: Context) -> UIView {
        let scanner = QRScanner()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let scanner = uiView as? QRScanner else { return }
        scanner.torchIsOn = torchIsOn
        scanner.isPaused = isPaused
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, QRScannerDelegate {
        var parent: QRScannerView

        init(_ parent: QRScannerView) {
            self.parent = parent
        }

        func qrScanner(_ scanner: QRScanner, didScan code: String) {
            parent.scannedCode = code
        }
    }
}

// Wrapper UIView pour le scanner (utilise AVFoundation) - Thread-safe
class QRScanner: UIView, AVCaptureMetadataOutputObjectsDelegate {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // Queue dédiée pour les opérations de capture (recommandé par Apple)
    private let sessionQueue = DispatchQueue(label: "xyz.consent69.qrscanner.session")
    private var isSessionRunning = false

    var torchIsOn = false {
        didSet {
            sessionQueue.async { [weak self] in
                self?.toggleTorch()
            }
        }
    }

    var isPaused = false {
        didSet {
            sessionQueue.async { [weak self] in
                self?.updateSessionState()
            }
        }
    }

    weak var delegate: QRScannerDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Délai pour laisser l'UI se stabiliser avant de configurer la caméra
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setupScanner()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.setupScanner()
        }
    }

    private func setupScanner() {
        // Configuration sur la queue dédiée
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            // Check device dispo en premier
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                print("DEBUG: No video capture device available.")
                return
            }

            let session = AVCaptureSession()
            session.beginConfiguration()

            do {
                let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                } else {
                    print("DEBUG: Could not add video input.")
                    session.commitConfiguration()
                    return
                }
            } catch {
                print("DEBUG: Error creating video input: \(error)")
                session.commitConfiguration()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                print("DEBUG: Could not add metadata output.")
                session.commitConfiguration()
                return
            }

            session.commitConfiguration()
            self.captureSession = session

            // Configuration du preview layer sur le main thread
            DispatchQueue.main.async {
                let layer = AVCaptureVideoPreviewLayer(session: session)
                layer.videoGravity = .resizeAspectFill
                layer.frame = self.bounds
                self.layer.addSublayer(layer)
                self.previewLayer = layer
            }

            // Démarrage de la session seulement si pas en pause
            if !self.isPaused {
                session.startRunning()
                self.isSessionRunning = session.isRunning
                print("DEBUG: QR Scanner session started.")
            } else {
                print("DEBUG: QR Scanner configured but paused - not starting.")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    private func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = torchIsOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("DEBUG: Torch toggle error: \(error)")
        }
    }

    // Met en pause ou reprend la capture vidéo (appelé depuis sessionQueue)
    private func updateSessionState() {
        guard let session = captureSession else { return }

        if isPaused {
            if session.isRunning {
                session.stopRunning()
                isSessionRunning = false
                print("DEBUG: QR Scanner paused.")
            }
        } else {
            if !session.isRunning {
                session.startRunning()
                isSessionRunning = session.isRunning
                print("DEBUG: QR Scanner resumed.")
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else { return }
        delegate?.qrScanner(self, didScan: stringValue)
    }

    deinit {
        sessionQueue.sync {
            captureSession?.stopRunning()
        }
    }
}

protocol QRScannerDelegate: AnyObject {
    func qrScanner(_ scanner: QRScanner, didScan code: String)
}

// Sheet pour afficher "Mon QR Code" (génère un QR avec Core Image) - Inchangé
struct MyQRCodeView: View {
    let qrData: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Mon Code QR")
                    .font(.title)
                    .fontWeight(.semibold)
                
                // Génère et affiche le QR
                QRCodeGenerator(data: qrData)
                    .frame(width: 200, height: 200)
                
                Text("Partagez ce code pour recevoir des consents.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

// Générateur QR avec Core Image - Inchangé
struct QRCodeGenerator: View {
    let data: String
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            generateQRCode()
        }
    }
    
    private func generateQRCode() {
        guard let data = data.data(using: .ascii) else { return }
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3) // Taille Apple-style
            if let output = filter.outputImage?.transformed(by: transform),
               let cgImage = CIContext().createCGImage(output, from: output.extent) {
                image = UIImage(cgImage: cgImage)
            }
        }
    }
}

// Preview pour Xcode
#Preview {
    QRScanConsentView()
}
