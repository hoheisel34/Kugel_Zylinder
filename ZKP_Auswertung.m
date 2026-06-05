% =========================================================================
%  MTP Versuch ZKP – Zylinder- und Kugelauswertung
%  Hochschule München, Fakultät Maschinenbau
%  Datum der Messung: 01.06.2026
% =========================================================================
%  Ausführungshinweis:
%    Beide CSV-Dateien müssen im selben Verzeichnis wie dieses Skript liegen.
%    MATLAB >= R2019b empfohlen.
%    Aufruf: ZKP_Auswertung()
% =========================================================================

clc; close all;

fprintf('=======================================================================\n');
fprintf('  MTP Versuch ZKP – Zylinderauswertung   (Messung 01.06.2026)\n');
fprintf('=======================================================================\n\n');

% -------------------------------------------------------------------------
%  1.  CSV-DATEIEN EINLESEN
% -------------------------------------------------------------------------
file_u  = 'VTP__01062026_Kugel_Zyl.CSV';    % unterkritisch
file_ue = 'VTP__01062026_Kugel_Zyl_2.CSV';  % überkritisch

[dp_u,  meta_u ] = readZKP_CSV(file_u );
[dp_ue, meta_ue] = readZKP_CSV(file_ue);
dp_ue(1) = 361;
% -------------------------------------------------------------------------
%  2.  TAGESWERTE  (aus Datei 1; beide Messungen gleicher Tag)
% -------------------------------------------------------------------------
% T_C   = meta_u.T_C;      % Temperatur          [°C]
% T_K   = T_C + 273.15;    % Temperatur          [K]
% p_hPa = meta_u.p_hPa;    % Luftdruck           [hPa]
% p_Pa  = p_hPa * 100;     % Luftdruck           [Pa]
% phi   = meta_u.phi;       % Luftfeuchtigkeit   [%]
% rho   = meta_u.rho;       % Luftdichte          [kg/m³]  (aus CSV)
% mu    = meta_u.mu;        % Dyn. Viskosität     [Pa·s]
% nu    = meta_u.nu;        % Kin. Viskosität     [m²/s]

T_C   = 22.7;      % Temperatur          [°C]
T_K   = T_C + 273.15;    % Temperatur          [K]
p_hPa = 956.;    % Luftdruck           [hPa]
p_Pa  = p_hPa * 100;     % Luftdruck           [Pa]
phi   = 57;       % Luftfeuchtigkeit   [%]
rho   = 1.12;       % Luftdichte          [kg/m³]  (aus CSV)
mu    = 0.000018;        % Dyn. Viskosität     [Pa·s]
nu    = 0.000016;        % Kin. Viskosität     [m²/s]

fprintf('TAGESWERTE:\n');
fprintf('  Temperatur T:      %.1f °C\n',  T_C);
fprintf('  Luftdruck p:       %.2f hPa\n', p_hPa);
fprintf('  Luftfeuchtigkeit:  %.0f %%\n',  phi);
fprintf('  Luftdichte  rho:   %.6f kg/m³\n', rho);
fprintf('  Dyn. Visk.  mu:    %.2e Pa·s\n',  mu);
fprintf('  Kin. Visk.  nu:    %.2e m²/s\n',  nu);

% -------------------------------------------------------------------------
%  3.  VERSUCHSPARAMETER
% -------------------------------------------------------------------------
D         = 0.110;      % Zylinderdurchmesser [m]
sin_theta = sin(30 * pi/180);  % Neigungsfaktor Schrägrohrmanometer (30°) = 0.5

% Staudruck aus Schrägrohrmanometern
skalen_u  = 300;
skalen_ue = 1300;
q_u  = skalen_u  * sin_theta;   % q∞ unterkritisch [Pa]
q_ue = skalen_ue * sin_theta;   % q∞ überkritisch  [Pa]

% Winkel (19 Bohrungen, 0° bis 180° in 10°-Schritten)
alpha_deg = (-10 : 10 : 170)';
alpha_rad = alpha_deg * pi / 180;

% -------------------------------------------------------------------------
%  4.  DRUCKBEIWERTE
% -------------------------------------------------------------------------
cp_u   = dp_u  / q_u;
cp_ue  = dp_ue / q_ue;
cp_pot = 1 - 4 * sin(alpha_rad).^2;   % Potentialtheorie (reibungsfrei)

% Kraft-Integrand in Strömungsrichtung
cp_cos_u   = cp_u   .* cos(alpha_rad);
cp_cos_ue  = cp_ue  .* cos(alpha_rad);
cp_cos_pot = cp_pot .* cos(alpha_rad);

% -------------------------------------------------------------------------
%  5.  STRÖMUNGSGESCHWINDIGKEIT UND REYNOLDSZAHL
% -------------------------------------------------------------------------
U_u  = sqrt(2 * q_u  / rho);   % [m/s]
U_ue = sqrt(2 * q_ue / rho);   % [m/s]

Re_u  = U_u  * D / nu;
Re_ue = U_ue * D / nu;

% -------------------------------------------------------------------------
%  6.  DRUCKWIDERSTANDSBEIWERT  cw_D  (Trapezregel)
%      cw_D = ∫₀^π  cp(α) · cos(α) dα
% -------------------------------------------------------------------------
cw_D_u   = trapz(alpha_rad, cp_cos_u);
cw_D_ue  = trapz(alpha_rad, cp_cos_ue);
cw_D_pot = trapz(alpha_rad, cp_cos_pot);

% -------------------------------------------------------------------------
%  7.  ERGEBNISAUSGABE
% -------------------------------------------------------------------------
fprintf('\n');
fprintf('──────────────────────────────────────────────────────────────────────\n');
fprintf('BETRIEBSPUNKTE\n');
fprintf('──────────────────────────────────────────────────────────────────────\n');
fprintf('%-30s %15s %15s\n', '',               'Unterkritisch', 'Überkritisch');
fprintf('%-30s %15.0f %15.0f\n', 'q∞  [Pa]',  q_u,  q_ue);
fprintf('%-30s %15.2f %15.2f\n', 'U∞  [m/s]', U_u,  U_ue);
fprintf('%-30s %15.1f %15.1f\n', 'U∞  [km/h]',U_u*3.6, U_ue*3.6);
fprintf('%-30s %15.0f %15.0f\n', 'Re',         Re_u, Re_ue);
fprintf('%-30s %15.4f %15.4f\n', 'cw_D (Trapezregel)', cw_D_u, cw_D_ue);
fprintf('%-30s %15.2e\n','cw_D Potentialtheorie', cw_D_pot);

fprintf('\nLITERATURVERGLEICH cw_D:\n');
fprintf('  Unterkritisch  gemessen: %.3f   Literatur: ≈ 1.0–1.2\n', cw_D_u);
fprintf('  Überkritisch   gemessen: %.3f   Literatur: ≈ 0.3–0.5\n', cw_D_ue);

% Wertetabelle
fprintf('\n');
fprintf('──────────────────────────────────────────────────────────────────────\n');
fprintf('WERTETABELLE  cp(α)  und  cp(α)·cos(α)\n');
fprintf('──────────────────────────────────────────────────────────────────────\n');
fprintf(' α[°]  │  Δp_u    cp_u  cp·cosα │  Δp_ü    cp_ü  cp·cosα │  cp_Pot\n');
fprintf('───────────────────────────────────────────────────────────────────────\n');
for i = 1 : length(alpha_deg)
    fprintf(' %4d  │ %6.0f  %6.3f  %7.3f │ %6.0f  %6.3f  %7.3f │ %7.3f\n', ...
        alpha_deg(i), ...
        dp_u(i),  cp_u(i),  cp_cos_u(i), ...
        dp_ue(i), cp_ue(i), cp_cos_ue(i), ...
        cp_pot(i));
end

% -------------------------------------------------------------------------
%  8.  DIAGRAMME
% -------------------------------------------------------------------------
colU   = [0.12, 0.47, 0.71];   % Blau
colUe  = [0.20, 0.63, 0.17];   % Grün
colPot = [0.89, 0.10, 0.11];   % Rot
lw     = 1.8;

alpha_plot=linspace(0,180,1000);
cp_pot_plot=sin(alpha_plot);

% --- Abbildung 1: cp(α) ---------------------------------------------------
fig1 = figure('Name','cp(alpha)','Position',[80 80 900 480]);
theme light
hold on; box on; grid on;
plot(alpha_deg, cp_pot, '-',  'Color',colPot,'LineWidth',lw+0.4, ...
     'DisplayName','Potentialtheorie');
plot(alpha_deg, cp_u,  '-o', 'Color',colU,  'LineWidth',lw, 'MarkerSize',6, ...
     'DisplayName', sprintf('Unterkritisch  Re = %.0e', Re_u));
plot(alpha_deg, cp_ue, '-s', 'Color',colUe, 'LineWidth',lw, 'MarkerSize',6, ...
     'DisplayName', sprintf('Überkritisch   Re = %.0e', Re_ue));
yline(0,'k:','LineWidth',0.8,'HandleVisibility','off');
% Anomalie-Annotierung
text(0, cp_u(1)-0.12,  'Verdrehung ~10°', 'FontSize',8,'Color',colU,  'HorizontalAlignment','center');
text(90,cp_u(11)+0.15,'Kanal 11',        'FontSize',8,'Color',colU,  'HorizontalAlignment','center');
text(160,cp_u(18)-0.15,'Kanal 18',        'FontSize',8,'Color',colU,  'HorizontalAlignment','center');

xlabel('\alpha [°]',  'FontSize',13);
ylabel('c_p [–]',     'FontSize',13);
title({'Druckbeiwert c_p als Funktion des Winkels \alpha', ...
       'Zylinderversuch – 01.06.2026'}, 'FontSize',12);
legend('Location','southwest','FontSize',10);
xlim([-10 170]);  xticks(-10:10:170);  ylim([-3.5 1.5]);
set(gca,'FontSize',11);
exportgraphics(fig1,'ZKP_cp_alpha.pdf','ContentType','vector','BackgroundColor','white');

% --- Abbildung 2: cp·cos(α) mit Schraffur --------------------------------
fig2 = figure('Name','cp*cos(alpha)','Position',[100 110 900 480]);
theme light
hold on; box on; grid on;

% Schattierte Flächen (∫ = cw_D)
fill([alpha_deg; flipud(alpha_deg)], ...
     [cp_cos_u;  zeros(size(cp_cos_u))],  colU,  ...
     'FaceAlpha',0.12,'EdgeColor','none','HandleVisibility','off');
fill([alpha_deg; flipud(alpha_deg)], ...
     [cp_cos_ue; zeros(size(cp_cos_ue))], colUe, ...
     'FaceAlpha',0.12,'EdgeColor','none','HandleVisibility','off');

plot(alpha_deg, cp_cos_pot, '-',  'Color',colPot,'LineWidth',lw+0.4, ...
     'DisplayName',sprintf('Potentialtheorie  c_{wD} = %.4f', cw_D_pot));
plot(alpha_deg, cp_cos_u,  '-o', 'Color',colU,  'LineWidth',lw, 'MarkerSize',6, ...
     'DisplayName',sprintf('Unterkritisch     c_{wD} = %.4f', cw_D_u));
plot(alpha_deg, cp_cos_ue, '-s', 'Color',colUe, 'LineWidth',lw, 'MarkerSize',6, ...
     'DisplayName',sprintf('Überkritisch      c_{wD} = %.4f', cw_D_ue));
yline(0,'k:','LineWidth',0.8,'HandleVisibility','off');

xlabel('\alpha [°]',              'FontSize',13);
ylabel('c_p \cdot cos( \alpha ) [-]', 'FontSize',13);

title({'c_p \cdot cos( \alpha ) - Druckwiderstandsanteil c_{wD}', ...
       'von \int c_p \cdot cos( \alpha )'});
legend('Location','northwest','FontSize',10);
xlim([-10 170]);  xticks(-10:10:170);  ylim([-2.0 2.0]);
set(gca,'FontSize',11);
exportgraphics(fig2,'ZKP_cp_cos_alpha.pdf','ContentType','vector','BackgroundColor','white');

fprintf('\nDiagramme gespeichert: ZKP_cp_alpha.pdf, ZKP_cp_cos_alpha.pdf\n');
fprintf('Fertig.\n\n');


% =========================================================================
%  LOKALE HILFSFUNKTION: CSV-Parser für ZKP-Messdateien
% =========================================================================
function [dp, meta] = readZKP_CSV(filename)
% readZKP_CSV  Liest eine ZKP-Messdatei (Semikolon-getrennt, Windows-1252).
%
%   Ausgaben:
%     dp   – (19×1) double: Druckdifferenzen der Zylinderbohrungen [Pa]
%              dp(1) → α=0°,  dp(2) → α=10°, ..., dp(19) → α=180°
%     meta – struct mit Tageswerten:
%              .T_C, .p_hPa, .phi, .rho, .mu, .nu, .Bezeichnung, .Datum

    if ~isfile(filename)
        error('Datei nicht gefunden: %s', filename);
    end

    % Datei einlesen (Windows-1252 / Latin-1)
    fid = fopen(filename, 'r', 'n', 'windows-1252');
    lines = {};
    while ~feof(fid)
        lines{end+1} = fgetl(fid);  %#ok<AGROW>
    end
    fclose(fid);
    

    % --- Tageswerte aus Header-Zeilen extrahieren ---
    meta = struct('T_C',NaN,'p_hPa',NaN,'phi',NaN,'rho',NaN,'mu',NaN,'nu',NaN, ...
                  'Bezeichnung','','Datum','');

    for k = 1:min(8, numel(lines))
        tok = strsplit(strtrim(lines{k}), ';');
        tok = strtrim(tok);

        % Zeile 2: Bezeichnung
        if numel(tok) >= 2 && strcmpi(tok{1},'Messung:')
            meta.Bezeichnung = tok{2};
        end
        % Zeile 3: Bezeichnung (Grenzschichttyp) + Temperatur
        if numel(tok) >= 6 && contains(lines{k}, 'Temperatur')
            meta.T_C = str2double(strrep(tok{6},',','.'));
        end
        % Zeile 4: Datum + Dichte
        if numel(tok) >= 2 && strcmpi(tok{1},'Datum:')
            meta.Datum = tok{2};
        end
        if numel(tok) >= 10 && contains(lines{k}, 'Luftdichte')
            meta.rho = str2double(strrep(tok{10},',','.'));
        end
        % Zeile 5: Luftfeuchtigkeit + Druck
        if numel(tok) >= 6 && contains(lines{k}, 'Luftfeuchtigkeit')
            meta.phi = str2double(strrep(tok{6},',','.'));
        end
        if numel(tok) >= 10 && contains(lines{k}, 'Druck')
            meta.p_hPa = str2double(strrep(tok{10},',','.'));
        end
        % Zeilen 6–7: Viskositäten
        if numel(tok) >= 10 && contains(lines{k}, 'Pa*sec')
            meta.mu = str2double(strrep(tok{10},',','.'));
        end
        if numel(tok) >= 10 && contains(lines{k}, 'm^2/sec')
            meta.nu = str2double(strrep(tok{10},',','.'));
        end
    end

    % --- Kanaldaten einlesen (Zeile mit "Kanal;Druck" suchen) ---
    data_start = 0;
    for k = 1:numel(lines)
        if contains(lines{k}, 'Kanal') && contains(lines{k}, 'Druck')
            data_start = k + 1;
            break;
        end
    end
    if data_start == 0
        error('Datenblock nicht gefunden in: %s', filename);
    end

    % Kanal–Druck-Paare lesen
    %   Format: "1;73;;17;-166;;33;0;;"
    % Kanal–Druck-Paare lesen
channels  = NaN(48,1);
pressures = NaN(48,1);

for k = data_start:numel(lines)

    tok = strsplit(lines{k}, ';');

    % In jeder Zeile stehen maximal drei Datensätze:
    % Kanal ; Druck ; Leer ; Kanal ; Druck ; Leer ; Kanal ; Druck ; Leer
    for col = [1 4 7]

        if col + 1 > numel(tok)
            continue;
        end

        ch = str2double(strtrim(tok{col}));

        pr = str2double( ...
            strrep(strtrim(tok{col+1}), ',', '.') );

        if isnan(ch)
            continue;
        end

        if ch >= 1 && ch <= 48
            channels(ch)  = ch;
            pressures(ch) = pr;
        end

    end
end

    % Nur Kanäle 1–19 (Zylinderbohrungen α = 0°, 10°, ..., 180°
    dp = pressures(1:19);

    % Fallback: Fehlende Tageswerte aus Gaskonstante schätzen
    if isnan(meta.rho) && ~isnan(meta.T_C) && ~isnan(meta.p_hPa)
        meta.rho = meta.p_hPa * 100 / (287.05 * (meta.T_C + 273.15));
    end
    if isnan(meta.mu) && ~isnan(meta.T_C)
        T = meta.T_C + 273.15;
        meta.mu = 1.458e-6 * T^1.5 / (T + 110.4);
    end
    if isnan(meta.nu) && ~isnan(meta.rho) && ~isnan(meta.mu)
        meta.nu = meta.mu / meta.rho;
    end
end

% =========================================================================
% Aufruf: ZKP_Kugel()   (separat ausführbar)
fprintf('=======================================================================\n');
fprintf('  MTP Versuch ZKP – Kugelauswertung   (Messung 01.06.2026)\n');
fprintf('=======================================================================\n\n');
 
% -------------------------------------------------------------------------
%  TAGESWERTE (identisch mit Zylinderversuch)
% -------------------------------------------------------------------------
rho = 1.1194;    % Luftdichte        [kg/m³]
nu  = 1.60e-5;   % Kin. Viskosität   [m²/s]
g_N = 9.807;     % N pro Kilopond    [N/kp]
 
% -------------------------------------------------------------------------
%  KUGELPARAMETER
% -------------------------------------------------------------------------
d_K = 0.250;                        % Kugeldurchmesser   [m]
A_K = pi / 4 * d_K^2;               % Referenzfläche     [m²]
sin_theta = 0.5;                    % Schrägrohrneigung 1:2 (sin30°)
 
% -------------------------------------------------------------------------
%  MESSWERTE
%  Schrägrohr-Skalenteile [Pa*] → q∞ = skalen × sin(30°)
% -------------------------------------------------------------------------
skalen   = [80, 120, 240, 320, 360, 400, 440, 520, 600, 800, 1000, 1400];
q_inf    = skalen * sin_theta;   % [Pa]
 
% W_ges [kp] – aus WhatsApp-Bild (Notation: kp/N = x / x×10)
W_ges_kp = [0.111, 0.148, 0.224, 0.196, 0.223, 0.253, 0.294, 0.371, ...
            0.420, 0.536, 0.666, 0.977];
W_ges_N  = W_ges_kp * g_N;       % Umrechnung kp → N
 
% W_Aufhängung [N] – aus PDF (vom Diagramm abgelesen, Team Kom)
W_Auf_N  = [0.28, 0.36, 0.70, 0.93, 1.07, 1.30, 1.58, 1.84, ...
            2.12, 2.87, 3.57, 5.00];
 
% Δp_Heck [Pa] – aus PDF rechte Spalte (= linke Spalte × sin30° = × 0.5)
% Linke Spalte (Pa*): -20,-30,-20,+30,+40,+50,+70,+100,+120,+180,+220,+320
%                      LP3 = -20 Pa* (handschriftlich abgelesen, nicht -80)
dp_Heck_star = [-20,-30,-20,+30,+40,+50,+70,+100,+120,+180,+220,+320];
dp_Heck      = dp_Heck_star * sin_theta;  % [Pa]
 
% -------------------------------------------------------------------------
%  BERECHNUNGEN
% -------------------------------------------------------------------------
W_Kugel = W_ges_N - W_Auf_N;              % Kugelwiderstand  [N]
U_inf   = sqrt(2 * q_inf / rho);          % Anströmgeschw.   [m/s]
Re      = U_inf * d_K / nu;               % Reynoldszahl     [-]
cw      = W_Kugel ./ (q_inf * A_K);       % Widerstandsbeiwert
cp_Heck = dp_Heck ./ q_inf;              % Druckbeiwert Heck
 
% -------------------------------------------------------------------------
%  KONSOLENAUSGABE
% -------------------------------------------------------------------------
fprintf('%-4s | %-7s | %-9s | %-9s | %-9s | %-8s | %-8s | %-9s | %-8s | %-7s\n', ...
    'LP','q[Pa]','U[m/s]','Re','W_ges[N]','W_Auf[N]','W_K[N]','dp_H[Pa]','cw','cp');
fprintf('%s\n', repmat('-',1,100));
for i = 1:12
    fprintf('%-4d | %-7.0f | %-9.2f | %-9.0f | %-9.3f | %-8.2f | %-8.3f | %-9.0f | %-8.4f | %-7.4f\n', ...
        i, q_inf(i), U_inf(i), Re(i), W_ges_N(i), W_Auf_N(i), W_Kugel(i), dp_Heck(i), cw(i), cp_Heck(i));
end
 
% -------------------------------------------------------------------------
%  TURBULENZFAKTOR
% -------------------------------------------------------------------------
Re_krit_ungest = 4.05e5;    % ungestörte kritische Re-Zahl der Kugel
 
% ---- Automatische Klammersuche: welche zwei aufeinanderfolgenden LP
%      schließen den gesuchten Schwellwert ein? ----
cw_krit = 0.3;
cp_krit = -0.22;
 
% cw = 0.3: suche Vorzeichenwechsel von (cw - 0.3)
i1 = find( (cw(1:end-1) - cw_krit) .* (cw(2:end) - cw_krit) < 0, 1 );
if isempty(i1)
    error('Kein Schnittpunkt cw = %.2f gefunden – Messdaten prüfen!', cw_krit);
end
i2 = i1 + 1;
f_cw       = (cw(i1) - cw_krit) / (cw(i1) - cw(i2));
Re_krit_cw = Re(i1) + f_cw * (Re(i2) - Re(i1));
 
% cp = -0.22: suche Vorzeichenwechsel von (cp - (-0.22))
i3 = find( (cp_Heck(1:end-1) - cp_krit) .* (cp_Heck(2:end) - cp_krit) < 0, 1 );
if isempty(i3)
    error('Kein Schnittpunkt cp = %.2f gefunden – Messdaten prüfen!', cp_krit);
end
i4 = i3 + 1;
f_cp       = (cp_Heck(i3) - cp_krit) / (cp_Heck(i3) - cp_Heck(i4));
Re_krit_cp = Re(i3) + f_cp * (Re(i4) - Re(i3));
 
fprintf('  Klammerpaar cw: LP%d (cw=%.4f) – LP%d (cw=%.4f)\n', i1,cw(i1),i2,cw(i2));
fprintf('  Klammerpaar cp: LP%d (cp=%.4f) – LP%d (cp=%.4f)\n', i3,cp_Heck(i3),i4,cp_Heck(i4));
 
Re_krit_mean = (Re_krit_cw + Re_krit_cp) / 2;
TF           = Re_krit_ungest / Re_krit_mean;
 
fprintf('\nTURBULENZFAKTOR:\n');
fprintf('  Re_krit aus cw = 0.3:       %.0f\n', Re_krit_cw);
fprintf('  Re_krit aus cp = -0.22:     %.0f\n', Re_krit_cp);
fprintf('  Mittelwert Re_krit:         %.0f\n', Re_krit_mean);
fprintf('  TF = Re_krit,ungest / Re_krit,mess = %.0f / %.0f = %.3f\n', ...
        Re_krit_ungest, Re_krit_mean, TF);
 
% -------------------------------------------------------------------------
%  DIAGRAMME
% -------------------------------------------------------------------------
colCw  = [0.12, 0.47, 0.71];
colCp  = [0.20, 0.63, 0.17];
lw     = 1.8;
 
% --- Abbildung 3: cw und cp über Re --------------------------------------
fig3 = figure('Name','Kugel cw und cp','Position',[120 120 920 500]);
theme light
hold on; box on; grid on;
 
yyaxis left
plot(Re, cw, '-o', 'Color',colCw,'LineWidth',lw,'MarkerSize',6, ...
     'DisplayName','c_w');
yline(0.3,'--','Color',colCw,'LineWidth',1.2,'HandleVisibility','off');
text(Re_krit_cw, 0.3+0.02, sprintf('Re_{krit,cw} = %.0f', Re_krit_cw), ...
     'FontSize',8,'Color',colCw,'HorizontalAlignment','center');
ylabel('c_w [–]','Color',colCw,'FontSize',13);
ylim([0 0.5]);
 
yyaxis right
plot(Re, cp_Heck, '-s', 'Color',colCp,'LineWidth',lw,'MarkerSize',6, ...
     'DisplayName','c_{p,Heck}');
yline(-0.22,'--','Color',colCp,'LineWidth',1.2,'HandleVisibility','off');
text(Re_krit_cp, -0.22-0.03, sprintf('Re_{krit,cp} = %.0f', Re_krit_cp), ...
     'FontSize',8,'Color',colCp,'HorizontalAlignment','center');
yline(0,'k:','LineWidth',0.8,'HandleVisibility','off');
ylabel('c_{p,Heck} [–]','Color',colCp,'FontSize',13);
ylim([-0.5 0.35]);
 
xline(Re_krit_mean,'k-','LineWidth',1,'HandleVisibility','off');
text(Re_krit_mean, 0.48, sprintf('\\bar{Re}_{krit} = %.0f', Re_krit_mean), ...
     'FontSize',9,'HorizontalAlignment','center');
 
xlabel('Re [–]','FontSize',13);
title({sprintf('Kugel – c_w und c_{p,Heck} über Reynoldszahl (d = %.0f mm)', d_K*1000), ...
    sprintf('TF = Re_{krit,ungest} / Re_{krit,mess} = %.0f / %.0f = %.3f', ...
            Re_krit_ungest, Re_krit_mean, TF)}, 'FontSize',11);
legend('Location','northeast','FontSize',10);
set(gca,'FontSize',11);
exportgraphics(fig3,'ZKP_Kugel_cw_cp.pdf','ContentType','vector','BackgroundColor','white');
 
fprintf('\nDiagramm gespeichert: ZKP_Kugel_cw_cp.pdf\n');
fprintf('Fertig.\n\n');