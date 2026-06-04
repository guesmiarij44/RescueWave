# Chapitre : Partie Électrique et Système Embarqué — RescueWave

---

## 1. Introduction

Ce chapitre présente l'ensemble de la partie électrique et électronique du bateau sauveteur autonome **RescueWave**. Ce bateau, dont les dimensions sont **1 m de longueur, 0,5 m de largeur et 0,3 m de hauteur**, est conçu pour opérer en milieu aquatique afin de détecter et secourir des victimes en situation de noyade. La conception électrique s'articule autour d'un cerveau central — le **Raspberry Pi 5** — qui orchestre l'ensemble des capteurs, des actionneurs et des communications.

Le système repose sur trois grandes parties fonctionnelles classiques en automatique industrielle :

- **La partie opérative** : l'ensemble des actionneurs et des éléments mécaniques qui agissent physiquement sur le bateau et son environnement.
- **La partie commande** : le calculateur principal et ses circuits de traitement qui pilotent la partie opérative en fonction des informations reçues des capteurs.
- **La partie homme-machine (IHM)** : l'interface entre le système et l'opérateur humain (maître-nageur), comprenant l'application mobile et les signaux d'alarme embarqués.

---

## 2. Architecture Générale du Système

Le bateau RescueWave est un système autonome communicant. Son architecture se décompose en quatre blocs fonctionnels interconnectés :

1. **Bloc de détection** : caméra Raspberry Pi + capteur LiDAR + capteur IMU → détection visuelle et de proximité de la victime.
2. **Bloc de navigation** : module GPS + IMU + servo-moteur + moteur brushless → déplacement autonome vers la victime.
3. **Bloc d'alarme embarquée** : LED + buzzer → signalisation visuelle et sonore à bord du bateau.
4. **Bloc de communication** : WiFi intégré Raspberry Pi 5 → transmission des alertes et du flux vidéo vers Firebase puis vers l'application mobile.

---

**[ Emplacement — Figure : Architecture générale du système embarqué RescueWave ]**

---

## 3. Partie Opérative

### 3.1 Définition

La **partie opérative** (PO) représente l'ensemble des éléments qui effectuent les actions physiques sur le système ou sur l'environnement. Elle comprend les actionneurs (moteurs, servos, LED, buzzer) et les mécanismes qu'ils entraînent (hélice, gouvernail). La PO reçoit des ordres de la partie commande sous forme de signaux électriques (PWM, GPIO logique) et les convertit en énergie mécanique, lumineuse ou sonore.

### 3.2 Les Actionneurs

#### 3.2.1 Moteur Brushless et Hélice

| Caractéristique | Valeur |
|---|---|
| Type | Moteur brushless DC (BLDC) trifasé outrunner |
| KV (tours/min par volt) | 1000 – 1400 KV |
| Tension d'alimentation | 11,1 V (LiPo 3S) |
| Courant nominal | 20 – 30 A |
| Puissance maximale | ~300 W |
| Interface de commande | Signal PWM via ESC (1000 – 2000 µs) |
| Diamètre hélice | 3 pouces (compatible avec la largeur du bateau) |
| Rôle | Propulsion du bateau |

Le moteur brushless est couplé à une hélice tripale qui génère la poussée propulsive. L'absence de charbons (brushless) garantit une durée de vie accrue et une meilleure résistance à l'humidité, critère essentiel pour un usage en milieu aquatique.

---

**[ Emplacement — Figure : Moteur brushless et connexion à l'hélice ]**

---

#### 3.2.2 Contrôleur ESC (Electronic Speed Controller)

| Caractéristique | Valeur |
|---|---|
| Courant maximal | 30 A |
| Tension d'alimentation | 7,4 V – 11,1 V (2S – 3S LiPo) |
| BEC intégré | 5 V / 3 A (alimentation servo et électronique) |
| Signal de commande | PWM 50 Hz (depuis GPIO Raspberry Pi) |
| Plage de commande | 1000 µs (arrêt) → 2000 µs (pleine vitesse) |

L'ESC (Electronic Speed Controller) est le convertisseur de puissance intermédiaire entre la batterie LiPo et le moteur brushless. Il reçoit un signal PWM de basse puissance émis par le Raspberry Pi et le traduit en commutation de courant haute puissance sur les trois phases du moteur brushless, régulant ainsi sa vitesse de rotation. L'ESC dispose également d'un **BEC (Battery Eliminator Circuit)** qui fournit une tension régulée de 5 V pour alimenter le servo-moteur et d'autres périphériques.

---

**[ Emplacement — Figure : Schéma de connexion ESC – moteur brushless – batterie LiPo ]**

---

#### 3.2.3 Servo-Moteur de Direction

| Caractéristique | Valeur |
|---|---|
| Modèle | MG996R (métal gear) |
| Tension d'alimentation | 4,8 V – 7,2 V |
| Couple | 9,4 kg·cm à 5 V |
| Angle de rotation | 0° – 180° (utilisé entre 60° et 120° pour gouvernail ±30°) |
| Signal de commande | PWM 50 Hz (depuis GPIO Raspberry Pi) |
| Impulsion | 1 ms = gauche / 1,5 ms = centre / 2 ms = droite |
| Rôle | Pilotage du gouvernail pour la direction |

---

**[ Emplacement — Figure : Servo-moteur MG996R et montage sur le gouvernail ]**

---

#### 3.2.4 LED d'Alarme

| Caractéristique | Valeur |
|---|---|
| Type | LED haute luminosité (rouge/bleue clignotante) |
| Tension directe | 2 – 3,3 V |
| Résistance série | 220 Ω (pour limitation de courant à 15 mA sous 5 V) |
| Interface | GPIO Raspberry Pi (sortie logique 3,3 V via transistor NPN) |
| Rôle | Signalisation visuelle d'alarme sur le bateau |

Les LED sont montées en boîtier étanche en tête du bateau, visibles de loin. Elles sont activées dès qu'une victime est détectée ou dès que le maître-nageur confirme la mission. Elles clignotent à une fréquence de 2 Hz pour maximiser la visibilité.

#### 3.2.5 Buzzer d'Alarme

| Caractéristique | Valeur |
|---|---|
| Type | Buzzer piézo actif 5 V |
| Tension d'alimentation | 5 V |
| Courant de consommation | 30 – 40 mA |
| Fréquence sonore | 2,4 kHz (interne) |
| Interface | GPIO Raspberry Pi via transistor NPN (BC547) |
| Rôle | Signalisation sonore d'alarme à bord du bateau |

Le buzzer et les LED constituent le système d'alarme embarqué. En cas de non-réception de la confirmation de l'alerte par le maître-nageur sur l'application mobile dans un délai défini, le buzzer se déclenche automatiquement pour signaler la situation même sans connexion réseau.

#### 3.2.6 Ventilateur de Refroidissement

| Caractéristique | Valeur |
|---|---|
| Type | Ventilateur DC 5 V (40 mm × 40 mm) |
| Tension d'alimentation | 5 V |
| Débit d'air | ~5 CFM |
| Interface | GPIO Raspberry Pi (via transistor MOSFET) |
| Rôle | Refroidissement du Raspberry Pi 5 et de l'ESC dans le boîtier étanche |

Le boîtier étanche, bien que nécessaire pour la protection contre l'eau, crée un environnement thermique fermé. Le ventilateur assure la circulation de l'air interne pour maintenir la température du Raspberry Pi 5 en dessous de 70°C lors des traitements vidéo intensifs.

---

## 4. Partie Commande

### 4.1 Définition

La **partie commande** (PC) est le cerveau du système. Elle reçoit les informations des capteurs, les traite selon les algorithmes programmés, et envoie les ordres aux actionneurs de la partie opérative. Dans le bateau RescueWave, la partie commande est centralisée autour du **Raspberry Pi 5**.

### 4.2 Raspberry Pi 5 — Calculateur Principal

| Caractéristique | Valeur |
|---|---|
| Processeur | Broadcom BCM2712, quad-core ARM Cortex-A76 @ 2,4 GHz |
| RAM | 4 Go / 8 Go LPDDR4X-4267 |
| Stockage | MicroSD (32 Go minimum, Classe 10) |
| Connectivité | WiFi 802.11ac (2,4/5 GHz) + Bluetooth 5.0 (intégrés) |
| GPIO | 40 broches (PWM, I2C, SPI, UART, GPIO numérique) |
| Interfaces caméra | 2 ports CSI (MIPI) |
| Tension d'alimentation | 5 V / 5 A (via USB-C Power Delivery) |
| Consommation | ~12 W (en charge maximale) |
| Système d'exploitation | Raspberry Pi OS (Debian Bookworm 64-bit) |

Le Raspberry Pi 5 exécute simultanément plusieurs tâches critiques :

1. **Traitement vidéo en temps réel** : analyse du flux de la caméra via un modèle YOLO (ou similaire) pour la détection de victimes.
2. **Fusion de données capteurs** : combinaison des données GPS, IMU et LiDAR pour la navigation.
3. **Génération des signaux PWM** : contrôle du moteur brushless (via ESC) et du servo de direction.
4. **Communication WiFi** : envoi des alertes et du flux vidéo vers Firebase (cloud) via le réseau WiFi disponible.
5. **Gestion des alarmes** : activation des LED et du buzzer selon les états du système.

---

**[ Emplacement — Figure : Raspberry Pi 5 — Pinout GPIO utilisé dans RescueWave ]**

---

**Affectation des broches GPIO du Raspberry Pi 5 :**

| Broche GPIO | Fonction | Composant connecté |
|---|---|---|
| GPIO 12 (PWM0) | PWM 50 Hz | Signal ESC (moteur brushless) |
| GPIO 13 (PWM1) | PWM 50 Hz | Signal servo-moteur de direction |
| GPIO 17 | Sortie numérique | Transistor LED d'alarme |
| GPIO 27 | Sortie numérique | Transistor buzzer |
| GPIO 22 | Sortie numérique | Transistor ventilateur |
| GPIO 2 (SDA) | I2C Data | IMU MPU-6050 + ADC ADS1115 |
| GPIO 3 (SCL) | I2C Clock | IMU MPU-6050 + ADC ADS1115 |
| GPIO 14 (TXD) | UART TX | Module GPS (RX) |
| GPIO 15 (RXD) | UART RX | Module GPS (TX) |
| GPIO 0 (ID_SDA) | UART / USB | LiDAR (selon modèle) |
| CSI 0 | Interface caméra | Caméra Raspberry Pi |

### 4.3 Régulateur de Tension

Le système nécessite plusieurs niveaux de tension stables :

| Convertisseur | Entrée | Sortie | Charges alimentées |
|---|---|---|---|
| DC-DC Step-Down XL4016 | 11,1 V (LiPo) | 5 V / 5 A | Raspberry Pi 5 (USB-C) |
| BEC intégré à l'ESC | 11,1 V (LiPo) | 5 V / 3 A | Servo-moteur, ventilateur |
| Régulateur LM7805 / AMS1117-3.3 | 5 V | 3,3 V | Capteurs IMU, GPS (si 3,3 V) |

---

**[ Emplacement — Figure : Schéma de distribution de l'alimentation — RescueWave ]**

---

### 4.4 Convertisseur ADC (ADS1115)

| Caractéristique | Valeur |
|---|---|
| Type | ADS1115 — ADC 16 bits, 4 canaux |
| Interface | I2C (adresse 0x48) |
| Plage d'entrée | 0 – 4,096 V (gain configurable) |
| Taux de conversion | 8 – 860 échantillons/seconde |
| Rôle principal | Lecture de la tension batterie LiPo (via pont diviseur) |

Le Raspberry Pi 5 ne dispose pas d'entrées analogiques natives. Le convertisseur ADS1115 (I2C) comble ce manque en permettant la lecture de la tension de la batterie LiPo (après division par pont résistif 11,1 V → 3,3 V max), ainsi que tout autre signal analogique (capteurs de courant, etc.).

**Pont diviseur pour mesure tension LiPo :**
```
V_LiPo (11,1 V max) ──┬── R1 (10 kΩ) ──┬── ADS1115 AIN0
                       │                 │
                      GND              R2 (3,3 kΩ)
                                         │
                                        GND
```
V_AIN0 = V_LiPo × R2 / (R1 + R2) ≤ 3,3 V ✓

---

## 5. Partie Capteurs

### 5.1 Caméra Raspberry Pi (Module v2 / v3)

| Caractéristique | Valeur |
|---|---|
| Modèle | Raspberry Pi Camera Module v3 |
| Résolution | 12 MP (4608 × 2592) |
| Vidéo | 1080p à 50 fps / 720p à 100 fps |
| Interface | CSI (MIPI) — directement sur Raspberry Pi 5 |
| Angle de vue | 75° (standard) |
| Boîtier | Module étanche ou protégé par vitre acrylique sur le boîtier |
| Rôle | Capture vidéo en temps réel pour détection IA de la victime |

La caméra est positionnée à l'avant du bateau avec un angle d'inclinaison vers le bas d'environ 15° pour surveiller la surface de l'eau. Le Raspberry Pi 5 traite le flux vidéo en temps réel avec un modèle de détection de personnes (YOLO v8 nano, optimisé pour l'embarqué). Dès qu'une victime est détectée, une alerte est générée et les coordonnées GPS du bateau sont enregistrées.

**Principe de fonctionnement :**
1. Capture vidéo à 30 fps via `libcamera` / `picamera2`.
2. Inférence IA image par image → détection de personne en danger.
3. Si détection confirmée (plusieurs frames consécutives) → écriture alerte dans Firebase.
4. Transmission du flux MJPEG ou screenshot vers Firebase Storage.

### 5.2 Capteur LiDAR

| Caractéristique | Valeur |
|---|---|
| Modèle recommandé | TF-Luna (Benewake) ou TF-Mini Plus |
| Technologie | Time-of-Flight (ToF) laser infrarouge |
| Portée de mesure | TF-Luna : 0,2 – 8 m / TF-Mini Plus : 0,1 – 12 m |
| Précision | ±6 cm |
| Fréquence de mise à jour | 1 – 250 Hz (configurable) |
| Interface | UART (115200 baud) ou I2C (selon configuration) |
| Angle de faisceau | 2° |
| Consommation | 130 mA @ 5 V |
| Rôle | Mesure de distance à la victime, évitement d'obstacles |

Le LiDAR permet de mesurer précisément la distance entre le bateau et un objet (ou la victime) dans un axe frontal. Couplé à la caméra, il permet :
- De confirmer la présence d'un obstacle ou d'une victime à courte distance.
- D'arrêter le bateau automatiquement à une distance de sécurité (~0,5 m) de la victime pour éviter de la blesser.

### 5.3 Module GPS

| Caractéristique | Valeur |
|---|---|
| Modèle recommandé | u-blox NEO-M8N ou BN-220 |
| Protocole | NMEA 0183 (trames GGA, RMC) |
| Interface | UART (9600 baud par défaut, configurable) |
| Précision | 2,5 m CEP (sans correction) |
| Fréquence de mise à jour | 1 – 10 Hz |
| Antenne | Antenne céramique intégrée ou externe (patch) |
| Tension d'alimentation | 3,3 V ou 5 V (selon module) |
| Rôle | Localisation géographique du bateau, transmission coordonnées victimes |

Le module GPS est connecté au port UART du Raspberry Pi (`/dev/ttyS0` ou `/dev/ttyAMA0`). Les bibliothèques Python `gpsd` ou `pynmea2` analysent les trames NMEA pour extraire la latitude, la longitude et l'heure UTC. Ces données sont envoyées en temps réel vers Firebase pour affichage sur la carte GPS de l'application mobile.

### 5.4 Capteur IMU (MPU-6050)

| Caractéristique | Valeur |
|---|---|
| Modèle | InvenSense MPU-6050 |
| Composants | Accéléromètre 3 axes + Gyroscope 3 axes |
| Interface | I2C (adresse 0x68 / 0x69) |
| Plage accéléromètre | ±2g / ±4g / ±8g / ±16g (configurable) |
| Plage gyroscope | ±250 / ±500 / ±1000 / ±2000 °/s |
| Résolution | 16 bits par axe |
| Tension d'alimentation | 3,3 V |
| Rôle | Mesure d'inclinaison, de roulis, tangage et cap du bateau |

L'IMU MPU-6050 fournit les données d'orientation du bateau. Ces données sont utilisées pour :
- **Stabilisation** : détecter si le bateau penche (roulis > seuil) et déclencher une alarme.
- **Cap magnétique** : combiné avec un filtre complémentaire, estimer l'orientation du bateau pour la navigation autonome.
- **Fusion de données** : combinaison accéléromètre + gyroscope via filtre de Kalman ou filtre complémentaire pour une estimation stable de l'attitude.

---

**[ Emplacement — Figure : Tableau récapitulatif des capteurs — connexions et rôles ]**

---

## 6. Alimentation

### 6.1 Batterie LiPo

| Caractéristique | Valeur |
|---|---|
| Type | Lithium Polymère (LiPo) |
| Configuration | 3S (3 cellules en série) |
| Tension nominale | 11,1 V (3,7 V × 3) |
| Tension maximale (chargée) | 12,6 V (4,2 V × 3) |
| Tension minimale (déchargée) | 9,9 V (3,3 V × 3) |
| Capacité | 5 000 – 8 000 mAh |
| Décharge maximale (C-rating) | 30C → courant max = 150 – 240 A |
| Connecteur | XT60 |
| Autonomie estimée | 30 – 45 min (selon la charge moteur) |

La batterie LiPo 3S est la source d'énergie principale du bateau. Elle alimente directement l'ESC (moteur brushless) et, via les régulateurs de tension, toute l'électronique embarquée.

**Calcul de consommation estimée :**

| Composant | Courant typique | Tension | Puissance |
|---|---|---|---|
| Moteur brushless (mi-régime) | 10 A | 11,1 V | 111 W |
| Raspberry Pi 5 (charge max) | 2,4 A | 5 V | 12 W |
| Servo-moteur MG996R | 0,5 A | 5 V | 2,5 W |
| Caméra + LiDAR + GPS + IMU | 0,5 A | 5 V | 2,5 W |
| LED + Buzzer + Ventilateur | 0,3 A | 5 V | 1,5 W |
| **TOTAL estimé** | | | **~130 W** |

Avec une batterie de 5 000 mAh @ 11,1 V → **énergie totale = 55,5 Wh** → autonomie ≈ **25 min** à pleine charge moteur.

### 6.2 Distribution d'Alimentation

```
┌─────────────────────────────────────────────────────────────────────┐
│                        BATTERIE LiPo 3S (11,1V)                      │
│                              │ XT60                                   │
└──────────────────────────────┼──────────────────────────────────────┘
                               │
            ┌──────────────────┴──────────────────┐
            │                                      │
     ┌──────▼──────┐                      ┌────────▼────────┐
     │  ESC 30A    │                      │ DC-DC XL4016    │
     │(11,1V → 3ph)│                      │(11,1V → 5V/5A)  │
     └──────┬──────┘                      └────────┬────────┘
            │                                      │
     ┌──────▼──────┐              ┌────────────────┼──────────────────┐
     │   Moteur    │              │                │                  │
     │  Brushless  │     ┌────────▼──────┐  ┌─────▼──────┐  ┌────────▼──────┐
     │  + Hélice   │     │ Raspberry Pi 5│  │ BEC (ESC)  │  │ AMS1117-3.3   │
     └─────────────┘     │  (via USB-C)  │  │ 5V/3A      │  │ (3,3V)        │
                         └───────────────┘  └──────┬─────┘  └──────┬────────┘
                                                    │               │
                                             Servo-moteur    GPS, IMU (3,3V)
                                             Ventilateur
                                             LED, Buzzer
```

### 6.3 Protection Électrique

- **Fusible principal** : 30 A entre la batterie et l'ESC (protection contre courts-circuits).
- **Diode de roue libre** : en parallèle sur le buzzer et les bobines (protection contre back-EMF).
- **Condensateur de découplage** : 100 µF sur le bus 5 V (stabilisation tension sous variations de charge).
- **Protection LiPo** : l'ESC intègre une coupure automatique Low Voltage Cutoff (LVC) à 9,9 V (3,3 V/cellule).

---

## 7. Système de Direction

### 7.1 Principe de Fonctionnement

La direction du bateau RescueWave est assurée par un **servo-moteur** (MG996R) couplé mécaniquement à un **gouvernail** placé à la poupe (arrière) du bateau. Le gouvernail dévie le flux d'eau propulsé par l'hélice, créant ainsi une force de giration qui fait virer le bateau.

---

**[ Emplacement — Figure : Schéma mécanique du système de direction — servo + gouvernail ]**

---

### 7.2 Commande PWM du Servo-Moteur

Le Raspberry Pi 5 génère un signal **PWM à 50 Hz** (période = 20 ms) sur la broche GPIO 13. La largeur d'impulsion détermine la position angulaire du servo :

| Largeur d'impulsion | Position servo | Angle gouvernail | Direction bateau |
|---|---|---|---|
| 1 000 µs (1 ms) | 0° | −30° (gauche) | Virage à gauche |
| 1 500 µs (1,5 ms) | 90° | 0° (centré) | Tout droit |
| 2 000 µs (2 ms) | 180° | +30° (droite) | Virage à droite |

**Code Python de contrôle du servo (extrait) :**
```python
import pigpio

pi = pigpio.pi()
GPIO_SERVO = 13

def set_direction(angle_deg):
    # angle_deg : -30 (gauche) à +30 (droite)
    pulse_width = 1500 + (angle_deg * (500 / 30))
    pi.set_servo_pulsewidth(GPIO_SERVO, int(pulse_width))

# Exemples :
set_direction(0)    # Tout droit
set_direction(-30)  # Plein gauche
set_direction(20)   # Légèrement à droite
```

### 7.3 Algorithme de Navigation Autonome

Le Raspberry Pi 5 implémente un algorithme de navigation basé sur deux modes :

**Mode 1 — Navigation par coordonnées GPS :**
1. Réception des coordonnées cibles (position de la victime détectée).
2. Calcul de l'angle de cap nécessaire (bearing) entre position actuelle et cible.
3. Comparaison avec le cap courant fourni par l'IMU.
4. Correction de direction via le servo-moteur (contrôleur PID).
5. Ajustement de la vitesse moteur selon la distance (ralentissement à l'approche).

**Mode 2 — Navigation par vision (asservissement visuel) :**
1. Détection de la victime dans l'image caméra.
2. Calcul de l'écart latéral entre le centre de l'image et la victime détectée.
3. Correction proportionnelle de l'angle du servo-moteur.
4. Arrêt automatique si le LiDAR détecte une distance < 0,5 m.

---

**[ Emplacement — Figure : Diagramme de flux de l'algorithme de navigation autonome ]**

---

## 8. Câblage Électrique

### 8.1 Description Générale du Câblage

Le câblage électrique du bateau RescueWave est organisé en **quatre faisceaux** distincts pour faciliter la maintenance et limiter les interférences électromagnétiques :

- **Faisceau puissance (rouge/noir, section 2,5 mm²)** : batterie LiPo → ESC → moteur brushless.
- **Faisceau alimentation électronique (section 0,75 mm²)** : régulateurs → Raspberry Pi, servo, capteurs.
- **Faisceau signaux de commande (section 0,25 mm²)** : GPIO Raspberry Pi → ESC, servo, LED, buzzer.
- **Faisceau données capteurs (section 0,25 mm²)** : GPIO Raspberry Pi ↔ GPS, IMU, LiDAR.

### 8.2 Tableau des Connexions Principales

| Signal | Broche RPi 5 | Fils | Composant | Broche composant |
|---|---|---|---|---|
| PWM ESC | GPIO 12 | Jaune (signal) | ESC | Signal (fil blanc/jaune) |
| PWM Servo | GPIO 13 | Blanc | MG996R | Signal (fil orange) |
| Alarme LED | GPIO 17 | Vert | Base BC547 | Base (via R=1 kΩ) |
| Alarme Buzzer | GPIO 27 | Bleu | Base BC547 | Base (via R=1 kΩ) |
| Ventilateur | GPIO 22 | Violet | Gate MOSFET | Gate (via R=10 kΩ) |
| I2C SDA | GPIO 2 (Pin 3) | Bleu | IMU SDA + ADS1115 SDA | SDA |
| I2C SCL | GPIO 3 (Pin 5) | Jaune | IMU SCL + ADS1115 SCL | SCL |
| UART TX | GPIO 14 (Pin 8) | Vert → RX GPS | GPS | RX |
| UART RX | GPIO 15 (Pin 10) | Bleu → TX GPS | GPS | TX |
| USB | Port USB RPi5 | Câble USB | LiDAR | USB |
| CSI | Port CSI 0 | Nappe flex | Caméra RPi | Connecteur CSI |
| 5V | Pin 2 / 4 | Rouge | Tous 5 V | VCC |
| GND | Pin 6 / 9 / 14... | Noir | Tous | GND |

### 8.3 Schéma de Câblage Simplifié

```
                        ┌─────────────────────┐
                        │   RASPBERRY Pi 5    │
                        │                     │
  CSI ←──── Caméra     │ GPIO12 ────────────►│──── ESC Signal ──► Moteur
  USB ←──── LiDAR      │ GPIO13 ────────────►│──── Servo Signal ─► Direction
  I2C ←──── IMU/ADC    │ GPIO17 ─► BC547 ───►│──── LED alarme
  UART ←─── GPS        │ GPIO27 ─► BC547 ───►│──── Buzzer
                        │ GPIO22 ─► MOSFET ──►│──── Ventilateur
                        │                     │
                        │ 5V (USB-C) ◄────────│──── DC-DC XL4016 ◄─ LiPo
                        └─────────────────────┘
                                                    │
                              ESC ◄─────────────────┤ (11,1V direct)
                              Moteur brushless ◄──── ESC (3 fils phase)
```

---

**[ Emplacement — Figure : Schéma électrique complet câblé RescueWave (voir fichier ISIS/Proteus) ]**

---

## 9. Encombrement (Implantation des Composants)

### 9.1 Disposition Physique dans le Boîtier

Le boîtier étanche du bateau (1 m × 0,5 m × 0,3 m) est divisé en **trois zones fonctionnelles** :

---

**[ Emplacement — Figure : Vue de dessus — plan d'encombrement du boîtier ]**

---

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    VUE DE DESSUS — BOÎTIER (1m × 0,5m)                  │
│                                                                          │
│  ┌────────────┐   ┌─────────────────────────┐   ┌───────────────────┐   │
│  │  ZONE AV.  │   │      ZONE CENTRALE       │   │    ZONE ARR.      │   │
│  │            │   │                          │   │                   │   │
│  │ [Caméra]   │   │  [Raspberry Pi 5]        │   │ [ESC]             │   │
│  │ [LiDAR]    │   │  [GPS module]            │   │ [Moteur Brushless]│   │
│  │ [LED]      │   │  [IMU MPU-6050]          │   │ [Hélice]          │   │
│  │            │   │  [ADS1115]               │   │ [Servo direction] │   │
│  │            │   │  [DC-DC XL4016]          │   │ [Gouvernail]      │   │
│  │            │   │  [Ventilateur]           │   │                   │   │
│  │            │   │  [Buzzer]                │   │                   │   │
│  └────────────┘   └─────────────────────────┘   └───────────────────┘   │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐    │
│  │                    BATTERIE LiPo 3S                               │    │
│  │                    (toute la longueur du fond)                    │    │
│  └──────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Critères d'Implantation

- **Batterie en fond de cale** : abaisse le centre de gravité → meilleure stabilité.
- **Raspberry Pi au centre** : accès optimal aux câbles de toutes directions + refroidissement ventilateur.
- **Caméra et LiDAR à l'avant** : champ de vision maximal vers l'avant du bateau.
- **ESC et moteur à l'arrière** : câbles puissance courts entre batterie et ESC, puis ESC et moteur.
- **GPS en zone centrale haute** : antenne orientée vers le ciel, non obstruée.
- **LED en tête avant** : visibilité maximale pour les sauveteurs et la victime.

### 9.3 Tableau des Dimensions et Masses

| Composant | Dimensions approx. | Masse approx. |
|---|---|---|
| Raspberry Pi 5 | 85 × 56 × 17 mm | 51 g |
| Batterie LiPo 5000mAh 3S | 155 × 48 × 35 mm | 310 g |
| ESC 30A | 60 × 35 × 15 mm | 40 g |
| Moteur Brushless | Ø 28 × 30 mm | 55 g |
| Servo MG996R | 40 × 19 × 43 mm | 55 g |
| Module GPS NEO-M8N | 22 × 22 × 8 mm | 12 g |
| IMU MPU-6050 | 20 × 16 × 1 mm | 3 g |
| LiDAR TF-Luna | 35 × 21.25 × 13.5 mm | 5 g |
| Caméra Raspberry Pi | 25 × 23 × 9 mm | 3 g |
| DC-DC XL4016 | 60 × 48 × 14 mm | 35 g |
| ADS1115 | 25 × 17 × 5 mm | 3 g |
| **TOTAL estimé** | | **~575 g** |

---

## 10. Simulation ISIS (Proteus)

### 10.1 Présentation de l'Outil

**ISIS Proteus** est un logiciel de conception et de simulation de circuits électroniques développé par Labcenter Electronics. Il permet de concevoir des schémas électroniques et de les simuler virtuellement avant tout câblage physique. Dans le cadre de RescueWave, la simulation ISIS permet de :

- Vérifier le fonctionnement logique du câblage (alarmes, PWM, communication série).
- Tester les algorithmes de commande sans risque pour le matériel.
- Présenter le fonctionnement électrique de manière pédagogique.

> **Note :** Proteus ISIS ne dispose pas de composant natif Raspberry Pi. La simulation utilisera un **microcontrôleur Arduino Mega 2560** pour simuler la logique de commande, avec des composants équivalents pour les actionneurs.

### 10.2 Liste des Composants ISIS

| Composant ISIS | Représente dans RescueWave | Bibliothèque Proteus |
|---|---|---|
| Arduino Mega 2560 | Raspberry Pi 5 (logique) | `ARDUINO` |
| DC Motor + PWM | Moteur brushless + ESC | `MOTOR`, `ACTIVE` |
| SERVO | Servo-moteur MG996R | `SERVO` |
| LED-RED / LED-BLUE | LED d'alarme | `DEVICE` |
| BUZZER | Buzzer piézo | `ACTIVE` |
| VIRTUAL TERMINAL | Module GPS (UART NMEA) | `VIRTUAL INSTRUMENTS` |
| LDR / POT-LIN | Simulation capteur distance (LiDAR) | `DEVICE` |
| L298N | Simulation ESC (driver moteur) | `MOTOR DRIVERS` |
| LCD 16×2 | Affichage état système | `DISPLAY` |
| BC547 | Transistor commande buzzer/LED | `TRANSISTORS` |
| RESISTOR | Résistances de protection | `RESISTORS` |
| BATTERY | Batterie LiPo 11,1V | `POWER` |
| VCC / GND | Nœuds d'alimentation | - |

### 10.3 Schéma de Simulation ISIS — Description

**Bloc 1 — Commande moteur (PWM) :**
- Arduino Mega : Pin 9 (Timer PWM) → L298N IN1/IN2 → DC Motor (simulation brushless).
- Potentiomètre connecté à A0 → lecture analogique → variation vitesse moteur (simulation commande).

**Bloc 2 — Direction (servo) :**
- Arduino Mega : Pin 10 (Timer PWM) → Composant SERVO Proteus.
- La valeur de position est affichée sur l'angle du servo en simulation.

**Bloc 3 — Alarme LED + Buzzer :**
- Arduino Mega : Pin 4 → R (1 kΩ) → Base BC547 → Collecteur = LED cathode, Émetteur = GND.
- Arduino Mega : Pin 5 → R (1 kΩ) → Base BC547 → Collecteur = Buzzer −, Émetteur = GND.
- La LED clignote à 2 Hz et le buzzer s'active lors de la détection simulée.

**Bloc 4 — Communication GPS (Virtual Terminal) :**
- Arduino Mega : Serial1 (Pin 18 TX, 19 RX) → Virtual Terminal (9600 baud).
- Trame NMEA simulée envoyée par code : `$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A`.

**Bloc 5 — Lecture tension batterie (simulation ADC) :**
- Potentiomètre sur A1 → simulation de la chute de tension batterie.
- Si V < seuil (=2/3 de la plage) → Arduino active l'alerte batterie faible.

### 10.4 Code Arduino pour Simulation ISIS

```cpp
#include <Servo.h>

// Broches
const int PIN_ESC     = 9;   // PWM moteur brushless
const int PIN_SERVO   = 10;  // PWM servo direction
const int PIN_LED     = 4;   // LED alarme
const int PIN_BUZZER  = 5;   // Buzzer alarme
const int PIN_DISTANCE= A0;  // Potentiomètre = distance LiDAR simulée
const int PIN_BATTERY = A1;  // Potentiomètre = tension batterie simulée

Servo servoDirection;
Servo escControl;

bool victime_detectee = false;

void setup() {
  Serial.begin(9600);   // Moniteur série
  Serial1.begin(9600);  // Virtual Terminal GPS

  servoDirection.attach(PIN_SERVO);
  escControl.attach(PIN_ESC);

  pinMode(PIN_LED, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);

  // Initialisation ESC
  escControl.writeMicroseconds(1000);
  delay(2000);
  Serial.println("Systeme RescueWave - Pret");
}

void loop() {
  // Lecture capteurs simulés
  int dist_raw    = analogRead(PIN_DISTANCE);  // 0-1023
  int batt_raw    = analogRead(PIN_BATTERY);   // 0-1023
  float distance  = map(dist_raw, 0, 1023, 0, 800) / 100.0;  // 0-8m
  float v_batt    = map(batt_raw, 0, 1023, 99, 126) / 10.0;  // 9.9-12.6V

  // Détection victime (simulée : distance < 3m)
  victime_detectee = (distance < 3.0);

  if (victime_detectee) {
    // Alarme LED + Buzzer (clignotement 2 Hz)
    digitalWrite(PIN_LED, HIGH);
    digitalWrite(PIN_BUZZER, HIGH);
    delay(250);
    digitalWrite(PIN_LED, LOW);
    digitalWrite(PIN_BUZZER, LOW);
    delay(250);

    // Ralentissement moteur à l'approche
    int vitesse = map(distance * 100, 0, 300, 1000, 1600);
    escControl.writeMicroseconds(vitesse);

    // Arrêt si < 0.5m
    if (distance < 0.5) {
      escControl.writeMicroseconds(1000);
      Serial.println("ALERTE: Victime atteinte - Arret moteur");
    }

    // Centrage direction
    servoDirection.writeMicroseconds(1500);

  } else {
    // Navigation normale
    escControl.writeMicroseconds(1600);
    servoDirection.writeMicroseconds(1500);
    digitalWrite(PIN_LED, LOW);
    digitalWrite(PIN_BUZZER, LOW);
  }

  // Alerte batterie faible
  if (v_batt < 10.5) {
    Serial.print("BATTERIE FAIBLE: ");
    Serial.print(v_batt); Serial.println(" V");
    for (int i = 0; i < 3; i++) {
      digitalWrite(PIN_BUZZER, HIGH); delay(100);
      digitalWrite(PIN_BUZZER, LOW);  delay(100);
    }
  }

  // Envoi trame GPS simulée (Virtual Terminal)
  Serial1.println("$GPRMC,123519,A,3652.000,N,01012.000,E,0.0,0.0,120526,,,A*68");

  // Affichage état
  Serial.print("Dist: "); Serial.print(distance);
  Serial.print("m | Batt: "); Serial.print(v_batt);
  Serial.print("V | Victime: "); Serial.println(victime_detectee ? "OUI" : "NON");

  delay(500);
}
```

### 10.5 Instructions de Simulation ISIS (Étapes)

1. **Ouvrir Proteus ISIS** → Nouveau projet.
2. **Placer les composants** : Rechercher dans la bibliothèque avec les noms indiqués dans la section 10.2.
3. **Connecter les fils** selon le schéma de la section 10.3.
4. **Charger le code** : clic droit sur l'Arduino Mega → Properties → Program File → charger le `.hex` compilé depuis Arduino IDE.
5. **Démarrer la simulation** : bouton Play (▶).
6. **Tester les scénarios** :
   - Tourner le potentiomètre `A0` vers la gauche → distance simulée < 3 m → LED et buzzer s'activent, moteur ralentit.
   - Tourner `A0` à fond gauche → distance < 0,5 m → moteur s'arrête.
   - Tourner `A1` vers la gauche → tension batterie < 10,5 V → alerte batterie.
7. **Observer** la Virtual Terminal pour les trames GPS simulées.

---

**[ Emplacement — Figure : Capture d'écran du schéma ISIS Proteus — RescueWave ]**

---

## 11. Partie Homme-Machine (IHM)

### 11.1 Définition

La **partie homme-machine** (IHM ou HMI) désigne l'ensemble des interfaces permettant à l'opérateur humain de surveiller le système et d'interagir avec lui. Pour RescueWave, l'IHM comporte deux niveaux :

- **IHM embarquée** (sur le bateau) : LED et buzzer → communication avec l'environnement immédiat.
- **IHM distante** (sur smartphone) : application mobile Flutter/Firebase → communication avec le maître-nageur.

### 11.2 IHM Embarquée — Alarmes LED et Buzzer

| État du système | LED | Buzzer | Signification |
|---|---|---|---|
| En patrouille (normal) | Éteinte | Silence | Aucune victime détectée |
| Victime détectée | Clignotement rouge rapide (4 Hz) | 2 bips courts | Détection en cours |
| Alerte envoyée, en attente | Clignotement bleu lent (1 Hz) | Silence | Attente confirmation maître-nageur |
| Mission confirmée | Allumée fixe verte | Silence | Maître-nageur en route |
| Non-confirmée après 30 s | Clignotement rouge + bleu alterné | Bips continus | Alarme maximale |
| Batterie faible | Clignotement orange (2 Hz) | 3 bips brefs | Niveau batterie critique |

### 11.3 IHM Distante — Application Mobile RescueWave

L'application mobile (détaillée dans le chapitre dédié) constitue l'IHM principale pour le maître-nageur. Elle reçoit les alertes générées par le Raspberry Pi via Firebase et permet :

1. **Réception d'alerte push** : notification FCM sur le smartphone même en arrière-plan.
2. **Visualisation de la position GPS** : carte affichant l'emplacement exact de la victime détectée.
3. **Flux vidéo** (optionnel) : capture image de la caméra transmise avec l'alerte.
4. **Confirmation de mission** : bouton « Confirmer » → commande de désactivation de l'alarme sonore du bateau.
5. **Clôture de mission** : bouton « Mission terminée » → enregistrement dans l'historique.

### 11.4 Flux de Communication IHM Complète

```
   [CAMÉRA IA]                    [RASPBERRY Pi 5]
   Détection victime ──────────►  Traitement + alerte
                                       │
                                  [WiFi intégré]
                                       │
                                  [Firebase Cloud]
                                  ┌────┴──────────┐
                          [FCM Push Notification]  [Firestore DB]
                                  │                     │
                         [Smartphone                [Application
                          Maître-nageur]            Mobile Flutter]
                                  │
                         [Confirmation mission]
                                  │
                         [Firebase Firestore]
                                  │
                         [Raspberry Pi ← WiFi]
                                  │
                         [Désactivation buzzer]
                         [LED : mission confirmée]
```

---

## 12. Conclusion

Ce chapitre a présenté l'ensemble de la partie électrique du bateau sauveteur autonome **RescueWave**, en suivant la décomposition classique en trois parties fonctionnelles :

- La **partie opérative** regroupe les actionneurs (moteur brushless, ESC, servo-moteur, LED, buzzer, ventilateur) qui agissent physiquement sur le bateau et son environnement.
- La **partie commande** est centralisée autour du **Raspberry Pi 5**, secondé par un régulateur de tension DC-DC et un convertisseur ADC, qui orchestrent la détection, la navigation et les communications.
- La **partie capteurs** comprend la caméra IA, le LiDAR, le GPS et l'IMU, qui fournissent la connaissance de l'environnement nécessaire à la prise de décision autonome.
- L'**alimentation** repose sur une batterie LiPo 3S 5000 mAh offrant une autonomie d'environ 30 minutes.
- Le **système de direction** combine un servo-moteur MG996R et un gouvernail, commandé par PWM depuis le Raspberry Pi, avec un algorithme de navigation par cap GPS ou asservissement visuel.
- Le **câblage électrique** est organisé en faisceaux distincts pour la puissance et les signaux, avec des protections (fusible, LVC, condensateurs de découplage).
- L'**encombrement** place la batterie en fond pour la stabilité, les capteurs à l'avant pour la détection, et la propulsion à l'arrière.
- La **simulation ISIS** dans Proteus, utilisant un Arduino Mega comme substitut du Raspberry Pi, permet de valider la logique d'alarme, de commande moteur et de direction avant le câblage physique.
- L'**IHM** combine les LED/buzzer embarqués pour la signalisation immédiate et l'application mobile Flutter pour la coordination à distance avec le maître-nageur.

L'ensemble de ce système électrique constitue la colonne vertébrale technologique de RescueWave, permettant au bateau d'opérer de manière autonome tout en maintenant une communication bidirectionnelle robuste avec le personnel de surveillance.
