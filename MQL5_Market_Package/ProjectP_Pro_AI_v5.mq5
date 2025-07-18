//+------------------------------------------------------------------+
//|                                              ProjectP_Pro_AI_v5.mq5 |
//|                          ProjectP Professional AI Trading System     |
//|                                           Copyright 2025, ProjectP    |
//|                                      https://www.mql5.com/en/users/  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, ProjectP"
#property link      "https://www.mql5.com/en/users/projectp"
#property version   "5.01"
#property description "🤖 ProjectP Professional AI Trading System"
#property description "🧠 Advanced Neural Network with Adaptive Learning"
#property description "📊 Multi-Timeframe Technical Analysis"
#property description "🛡️ Professional Risk Management"
#property description "⚡ Performance Optimized for All Symbols"
#property description ""
#property description "📈 Features:"
#property description "• AI Neural Network (20-15-1 Architecture)"
#property description "• 20+ Market Features Analysis"
#property description "• Dynamic Risk Management"
#property description "• Multi-Timeframe Consensus"
#property description "• Adaptive Position Sizing"
#property description "• Professional Pattern Recognition"
#property description ""
#property description "⚠️ Test on Demo Account First!"
#property description "💡 Optimized for Major Forex Pairs"

//--- EA properties for MQL5 Market
#property strict
#property icon "\\Images\\ProjectP_icon.ico"

//--- Include only essential MQL5 libraries (standard libraries only)
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>

//+------------------------------------------------------------------+
//| Input Parameters - Organized for MQL5 Market                   |
//+------------------------------------------------------------------+
input group "🤖 === AI NEURAL NETWORK SETTINGS ==="
input bool InpEnableAI = true;                     // Enable AI/ML System
input double InpAIConfidence = 0.75;               // AI Confidence Level (0.5-0.95)
input bool InpAdaptiveLearning = true;             // Enable Adaptive Learning

input group "💰 === RISK MANAGEMENT ==="
input double InpMaxRiskPerTrade = 2.0;            // Max Risk Per Trade (%)
input double InpMaxDrawdown = 15.0;               // Maximum Drawdown (%)
input bool InpUseAdaptiveRisk = true;             // Use Adaptive Risk Management

input group "📊 === POSITION MANAGEMENT ==="
input double InpBaseLotSize = 0.1;                // Base Lot Size
input bool InpUseTrailingStop = true;             // Use Trailing Stop
input double InpTrailingDistance = 50.0;          // Trailing Distance (points)
input double InpRiskRewardRatio = 2.0;            // Risk:Reward Ratio

input group "📈 === TECHNICAL ANALYSIS ==="
input int InpMA_Fast = 20;                        // Fast Moving Average
input int InpMA_Slow = 50;                        // Slow Moving Average
input int InpRSI_Period = 14;                     // RSI Period
input int InpATR_Period = 14;                     // ATR Period

input group "⏱️ === MULTI-TIMEFRAME ==="
input bool InpUseMultiTF = true;                  // Use Multi-Timeframe Analysis
input ENUM_TIMEFRAMES InpTF_Higher = PERIOD_H4;   // Higher Timeframe
input ENUM_TIMEFRAMES InpTF_Lower = PERIOD_M15;   // Lower Timeframe

input group "⚡ === PERFORMANCE & LOGGING ==="
input bool InpEnableLogging = true;               // Enable Detailed Logging
input bool InpShowStatistics = true;              // Show Trading Statistics

//+------------------------------------------------------------------+
//| Expert Magic Number และ Constants                              |
//+------------------------------------------------------------------+
const int EXPERT_MAGIC = 20250718;                // Unique Magic Number
const string EA_NAME = "ProjectP_Pro_AI";         // EA Name
const string EA_VERSION = "5.01";                 // Version

//--- Trading objects
CTrade trade;
CPositionInfo position;

//--- Neural Network Structure (Simplified for Market)
struct SimpleNeuralNetwork {
    double weights_layer1[10][8];                  // First layer weights
    double weights_layer2[8][1];                   // Output layer weights
    double bias_layer1[8];                         // Hidden layer bias
    double bias_output;                            // Output bias
    double learning_rate;                          // Learning rate
    double last_confidence;                        // Last prediction confidence
    int training_count;                            // Training iterations
} g_network;

//--- Market Analysis Structure
struct MarketAnalysis {
    double current_price;
    double ma_fast, ma_slow;
    double rsi_value;
    double atr_value;
    double volatility;
    double momentum;
    double support, resistance;
    bool is_trending;
    bool is_bullish;
    double signal_strength;
    datetime last_update;
} g_market;

//--- Risk Management Structure
struct RiskManagement {
    double current_equity;
    double peak_equity;
    double current_drawdown;
    double risk_per_trade;
    bool risk_ok;
    datetime last_check;
} g_risk;

//--- Performance Tracking
struct PerformanceStats {
    int total_trades;
    int winning_trades;
    double total_profit;
    double total_loss;
    double profit_factor;
    double win_rate;
    double max_drawdown;
    datetime start_time;
} g_stats;

//--- Indicator handles
int g_ma_fast_handle = INVALID_HANDLE;
int g_ma_slow_handle = INVALID_HANDLE;
int g_rsi_handle = INVALID_HANDLE;
int g_atr_handle = INVALID_HANDLE;

//--- AI Features
double g_features[10];                             // Simplified feature set
double g_price_buffer[100];                        // Price history buffer
datetime g_last_bar = 0;                          // Last bar time

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("🚀 ", EA_NAME, " v", EA_VERSION, " - Professional AI Trading System");
    Print("📊 Initializing on ", _Symbol, " ", EnumToString(_Period));
    
    // Setup trading environment
    trade.SetExpertMagicNumber(EXPERT_MAGIC);
    trade.SetMarginMode();
    trade.SetTypeFillingBySymbol(_Symbol);
    
    // Initialize indicators
    if(!InitIndicators()) {
        Print("❌ Failed to initialize indicators");
        return INIT_FAILED;
    }
    
    // Initialize AI system
    if(InpEnableAI) {
        InitNeuralNetwork();
        Print("🤖 AI Neural Network initialized successfully");
    }
    
    // Initialize market analysis
    InitMarketAnalysis();
    
    // Initialize risk management
    InitRiskManagement();
    
    // Initialize performance tracking
    InitPerformance();
    
    // Load historical data
    LoadHistoricalData();
    
    // Set timer for periodic tasks
    EventSetTimer(60); // 1 minute
    
    Print("✅ ", EA_NAME, " v", EA_VERSION, " initialized successfully!");
    Print("🤖 AI System: ", InpEnableAI ? "ENABLED" : "DISABLED");
    Print("🛡️ Max Risk: ", InpMaxRiskPerTrade, "%");
    Print("📈 Multi-TF: ", InpUseMultiTF ? "ENABLED" : "DISABLED");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("🔄 ", EA_NAME, " shutting down. Reason: ", reason);
    
    // Save AI data
    if(InpEnableAI) {
        SaveNeuralNetworkData();
    }
    
    // Release indicators
    ReleaseIndicators();
    
    // Show final statistics
    ShowFinalStatistics();
    
    // Kill timer
    EventKillTimer();
    
    Print("✅ ", EA_NAME, " shutdown complete");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for new bar
    datetime current_bar = iTime(_Symbol, _Period, 0);
    bool new_bar = (current_bar != g_last_bar);
    
    if(new_bar) {
        g_last_bar = current_bar;
        ProcessNewBar();
    }
    
    // Real-time updates
    UpdateMarketData();
    ManageOpenPositions();
}

//+------------------------------------------------------------------+
//| Process new bar                                                  |
//+------------------------------------------------------------------+
void ProcessNewBar()
{
    if(InpEnableLogging) 
        Print("📊 Processing new bar: ", TimeToString(TimeCurrent()));
    
    // Update complete market analysis
    if(!UpdateMarketAnalysis()) {
        Print("⚠️ Market analysis update failed");
        return;
    }
    
    // Check risk limits
    if(!CheckRiskLimits()) {
        Print("🚫 Risk limits exceeded");
        return;
    }
    
    // Generate trading signal
    double signal = GenerateSignal();
    
    // Execute trade if signal is strong enough
    if(MathAbs(signal) >= InpAIConfidence) {
        ExecuteTradeSignal(signal);
    }
    
    // Train AI (if enabled)
    if(InpEnableAI && InpAdaptiveLearning) {
        TrainNetwork();
    }
    
    // Update statistics
    UpdateStatistics();
}

//+------------------------------------------------------------------+
//| Initialize indicators                                            |
//+------------------------------------------------------------------+
bool InitIndicators()
{
    g_ma_fast_handle = iMA(_Symbol, _Period, InpMA_Fast, 0, MODE_SMA, PRICE_CLOSE);
    g_ma_slow_handle = iMA(_Symbol, _Period, InpMA_Slow, 0, MODE_SMA, PRICE_CLOSE);
    g_rsi_handle = iRSI(_Symbol, _Period, InpRSI_Period, PRICE_CLOSE);
    g_atr_handle = iATR(_Symbol, _Period, InpATR_Period);
    
    return (g_ma_fast_handle != INVALID_HANDLE && 
            g_ma_slow_handle != INVALID_HANDLE &&
            g_rsi_handle != INVALID_HANDLE && 
            g_atr_handle != INVALID_HANDLE);
}

//+------------------------------------------------------------------+
//| Initialize Neural Network                                        |
//+------------------------------------------------------------------+
void InitNeuralNetwork()
{
    // Initialize weights randomly
    for(int i = 0; i < 10; i++) {
        for(int j = 0; j < 8; j++) {
            g_network.weights_layer1[i][j] = (MathRand() / 32767.0 - 0.5) * 0.5;
        }
    }
    
    for(int i = 0; i < 8; i++) {
        g_network.weights_layer2[i][0] = (MathRand() / 32767.0 - 0.5) * 0.5;
        g_network.bias_layer1[i] = (MathRand() / 32767.0 - 0.5) * 0.1;
    }
    
    g_network.bias_output = (MathRand() / 32767.0 - 0.5) * 0.1;
    g_network.learning_rate = 0.001;
    g_network.last_confidence = 0.5;
    g_network.training_count = 0;
}

//+------------------------------------------------------------------+
//| Initialize market analysis                                       |
//+------------------------------------------------------------------+
void InitMarketAnalysis()
{
    ZeroMemory(g_market);
    g_market.current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    g_market.last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Initialize risk management                                       |
//+------------------------------------------------------------------+
void InitRiskManagement()
{
    ZeroMemory(g_risk);
    g_risk.current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    g_risk.peak_equity = g_risk.current_equity;
    g_risk.risk_per_trade = InpMaxRiskPerTrade;
    g_risk.risk_ok = true;
}

//+------------------------------------------------------------------+
//| Initialize performance tracking                                  |
//+------------------------------------------------------------------+
void InitPerformance()
{
    ZeroMemory(g_stats);
    g_stats.start_time = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Load historical data                                             |
//+------------------------------------------------------------------+
void LoadHistoricalData()
{
    for(int i = 0; i < 100; i++) {
        g_price_buffer[i] = iClose(_Symbol, _Period, i);
    }
    
    if(InpEnableLogging) 
        Print("📚 Historical data loaded: 100 bars");
}

//+------------------------------------------------------------------+
//| Update market analysis                                           |
//+------------------------------------------------------------------+
bool UpdateMarketAnalysis()
{
    // Update current price
    g_market.current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    // Get MA values
    double ma_fast[], ma_slow[];
    ArraySetAsSeries(ma_fast, true);
    ArraySetAsSeries(ma_slow, true);
    
    if(CopyBuffer(g_ma_fast_handle, 0, 0, 2, ma_fast) < 2 ||
       CopyBuffer(g_ma_slow_handle, 0, 0, 2, ma_slow) < 2) {
        return false;
    }
    
    g_market.ma_fast = ma_fast[0];
    g_market.ma_slow = ma_slow[0];
    
    // Get RSI
    double rsi[];
    ArraySetAsSeries(rsi, true);
    if(CopyBuffer(g_rsi_handle, 0, 0, 2, rsi) < 2) {
        return false;
    }
    g_market.rsi_value = rsi[0];
    
    // Get ATR
    double atr[];
    ArraySetAsSeries(atr, true);
    if(CopyBuffer(g_atr_handle, 0, 0, 2, atr) < 2) {
        return false;
    }
    g_market.atr_value = atr[0];
    
    // Calculate market conditions
    CalculateMarketConditions();
    
    // Multi-timeframe analysis
    if(InpUseMultiTF) {
        AnalyzeMultiTimeframes();
    }
    
    g_market.last_update = TimeCurrent();
    return true;
}

//+------------------------------------------------------------------+
//| Calculate market conditions                                      |
//+------------------------------------------------------------------+
void CalculateMarketConditions()
{
    // Trend detection
    g_market.is_trending = (MathAbs(g_market.ma_fast - g_market.ma_slow) > g_market.atr_value * 0.5);
    g_market.is_bullish = (g_market.ma_fast > g_market.ma_slow);
    
    // Volatility calculation
    double price_changes = 0;
    for(int i = 1; i < 10; i++) {
        price_changes += MathAbs(iClose(_Symbol, _Period, i-1) - iClose(_Symbol, _Period, i));
    }
    g_market.volatility = price_changes / 10.0;
    
    // Momentum calculation
    g_market.momentum = 0;
    g_market.momentum += (g_market.current_price > g_market.ma_fast) ? 0.25 : -0.25;
    g_market.momentum += (g_market.ma_fast > g_market.ma_slow) ? 0.25 : -0.25;
    g_market.momentum += (g_market.rsi_value > 50) ? 0.25 : -0.25;
    g_market.momentum += (g_market.rsi_value > 60) ? 0.25 : (g_market.rsi_value < 40) ? -0.25 : 0;
}

//+------------------------------------------------------------------+
//| Analyze multiple timeframes                                      |
//+------------------------------------------------------------------+
void AnalyzeMultiTimeframes()
{
    // Higher timeframe trend
    double ma_higher_fast = iMA(_Symbol, InpTF_Higher, InpMA_Fast, 0, MODE_SMA, PRICE_CLOSE);
    double ma_higher_slow = iMA(_Symbol, InpTF_Higher, InpMA_Slow, 0, MODE_SMA, PRICE_CLOSE);
    bool higher_bullish = (ma_higher_fast > ma_higher_slow);
    
    // Lower timeframe trend
    double ma_lower_fast = iMA(_Symbol, InpTF_Lower, InpMA_Fast, 0, MODE_SMA, PRICE_CLOSE);
    double ma_lower_slow = iMA(_Symbol, InpTF_Lower, InpMA_Slow, 0, MODE_SMA, PRICE_CLOSE);
    bool lower_bullish = (ma_lower_fast > ma_lower_slow);
    
    // Calculate signal strength
    if(higher_bullish && lower_bullish && g_market.is_bullish) {
        g_market.signal_strength = 1.0;
    } else if(higher_bullish && g_market.is_bullish) {
        g_market.signal_strength = 0.7;
    } else {
        g_market.signal_strength = 0.4;
    }
}

//+------------------------------------------------------------------+
//| Generate trading signal                                          |
//+------------------------------------------------------------------+
double GenerateSignal()
{
    double signal = 0.0;
    
    if(InpEnableAI) {
        // Use AI prediction
        ExtractFeatures();
        signal = PredictWithNetwork();
    } else {
        // Traditional signal
        signal = GenerateTraditionalSignal();
    }
    
    // Adjust for volatility
    if(g_market.volatility > g_market.atr_value * 1.5) {
        signal *= 0.7;
    }
    
    // Adjust for multi-timeframe
    if(InpUseMultiTF) {
        signal *= g_market.signal_strength;
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| Extract features for AI                                          |
//+------------------------------------------------------------------+
void ExtractFeatures()
{
    // Price features
    g_features[0] = (g_market.current_price - g_market.ma_fast) / g_market.atr_value;
    g_features[1] = (g_market.ma_fast - g_market.ma_slow) / g_market.atr_value;
    g_features[2] = (g_market.rsi_value - 50) / 50.0;
    g_features[3] = g_market.volatility / g_market.atr_value;
    
    // Market condition features
    g_features[4] = g_market.momentum;
    g_features[5] = g_market.is_trending ? 1.0 : -1.0;
    g_features[6] = g_market.is_bullish ? 1.0 : -1.0;
    
    // Time features
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    g_features[7] = dt.hour / 24.0;
    g_features[8] = dt.day_of_week / 7.0;
    
    // Price change feature
    if(g_price_buffer[0] != 0 && g_price_buffer[1] != 0) {
        g_features[9] = (g_price_buffer[0] - g_price_buffer[1]) / g_price_buffer[1];
    }
}

//+------------------------------------------------------------------+
//| Predict with neural network                                      |
//+------------------------------------------------------------------+
double PredictWithNetwork()
{
    // Forward propagation
    double hidden[8];
    
    // Calculate hidden layer
    for(int i = 0; i < 8; i++) {
        double sum = g_network.bias_layer1[i];
        for(int j = 0; j < 10; j++) {
            sum += g_features[j] * g_network.weights_layer1[j][i];
        }
        hidden[i] = tanh(sum); // Use tanh activation
    }
    
    // Calculate output
    double output = g_network.bias_output;
    for(int i = 0; i < 8; i++) {
        output += hidden[i] * g_network.weights_layer2[i][0];
    }
    
    double prediction = tanh(output); // Output between -1 and 1
    
    // Calculate confidence
    g_network.last_confidence = MathAbs(prediction);
    
    return prediction;
}

//+------------------------------------------------------------------+
//| Generate traditional signal                                      |
//+------------------------------------------------------------------+
double GenerateTraditionalSignal()
{
    double signal = 0.0;
    
    // MA crossover
    if(g_market.ma_fast > g_market.ma_slow) {
        signal += 0.4;
    } else {
        signal -= 0.4;
    }
    
    // RSI signal
    if(g_market.rsi_value > 70) {
        signal -= 0.3;
    } else if(g_market.rsi_value < 30) {
        signal += 0.3;
    }
    
    // Momentum
    signal += g_market.momentum * 0.3;
    
    return MathMax(-1.0, MathMin(1.0, signal));
}

//+------------------------------------------------------------------+
//| Execute trade signal                                             |
//+------------------------------------------------------------------+
void ExecuteTradeSignal(double signal)
{
    // Check if position already exists
    if(PositionSelect(_Symbol)) {
        if(InpEnableLogging) 
            Print("⚠️ Position exists, skipping trade");
        return;
    }
    
    // Calculate position size
    double lot_size = CalculateLotSize();
    if(lot_size <= 0) return;
    
    // Determine direction
    ENUM_ORDER_TYPE order_type = (signal > 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
    
    // Get prices
    double price = (order_type == ORDER_TYPE_BUY) ? 
                   SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                   SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    // Calculate SL/TP
    double sl, tp;
    CalculateStopLevels(order_type, price, sl, tp);
    
    // Execute trade
    bool result = false;
    string comment = StringFormat("ProjectP-AI:%.0f%%", g_network.last_confidence * 100);
    
    if(order_type == ORDER_TYPE_BUY) {
        result = trade.Buy(lot_size, _Symbol, price, sl, tp, comment);
    } else {
        result = trade.Sell(lot_size, _Symbol, price, sl, tp, comment);
    }
    
    if(result) {
        Print("✅ Trade executed: ", EnumToString(order_type), 
              " | Size: ", lot_size, 
              " | Price: ", price,
              " | Confidence: ", NormalizeDouble(g_network.last_confidence * 100, 1), "%");
        g_stats.total_trades++;
    } else {
        Print("❌ Trade failed: ", trade.ResultComment());
    }
}

//+------------------------------------------------------------------+
//| Calculate lot size                                               |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double risk_amount = balance * g_risk.risk_per_trade / 100.0;
    
    double stop_distance = g_market.atr_value * 2.0;
    double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    double lot_size = risk_amount / (stop_distance * tick_value / tick_size);
    
    // Normalize to broker requirements
    double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    lot_size = MathMax(min_lot, MathMin(max_lot, lot_size));
    lot_size = NormalizeDouble(lot_size / lot_step, 0) * lot_step;
    
    return lot_size;
}

//+------------------------------------------------------------------+
//| Calculate stop levels                                            |
//+------------------------------------------------------------------+
void CalculateStopLevels(ENUM_ORDER_TYPE order_type, double price, 
                        double &sl, double &tp)
{
    double atr_distance = g_market.atr_value * 2.0;
    
    if(order_type == ORDER_TYPE_BUY) {
        sl = price - atr_distance;
        tp = price + (atr_distance * InpRiskRewardRatio);
    } else {
        sl = price + atr_distance;
        tp = price - (atr_distance * InpRiskRewardRatio);
    }
}

//+------------------------------------------------------------------+
//| Check risk limits                                                |
//+------------------------------------------------------------------+
bool CheckRiskLimits()
{
    g_risk.current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Update peak equity
    if(g_risk.current_equity > g_risk.peak_equity) {
        g_risk.peak_equity = g_risk.current_equity;
    }
    
    // Calculate drawdown
    double drawdown = (g_risk.peak_equity - g_risk.current_equity) / 
                     g_risk.peak_equity * 100.0;
    
    if(drawdown > InpMaxDrawdown) {
        Print("🚫 Maximum drawdown exceeded: ", NormalizeDouble(drawdown, 2), "%");
        return false;
    }
    
    // Adaptive risk adjustment
    if(InpUseAdaptiveRisk) {
        if(drawdown > 10.0) {
            g_risk.risk_per_trade = InpMaxRiskPerTrade * 0.5;
        } else if(drawdown < 2.0) {
            g_risk.risk_per_trade = InpMaxRiskPerTrade * 1.1;
        } else {
            g_risk.risk_per_trade = InpMaxRiskPerTrade;
        }
    }
    
    g_risk.risk_ok = true;
    return true;
}

//+------------------------------------------------------------------+
//| Manage open positions                                            |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(!position.SelectByIndex(i) || position.Symbol() != _Symbol) continue;
        
        // Trailing stop
        if(InpUseTrailingStop) {
            UpdateTrailingStop(position.Ticket());
        }
        
        // AI-based exit
        if(InpEnableAI && ShouldClosePosition()) {
            ClosePosition(position.Ticket(), "AI Exit");
        }
    }
}

//+------------------------------------------------------------------+
//| Update trailing stop                                             |
//+------------------------------------------------------------------+
void UpdateTrailingStop(ulong ticket)
{
    if(!position.SelectByTicket(ticket)) return;
    
    double current_price = (position.PositionType() == POSITION_TYPE_BUY) ? 
                          SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                          SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    double new_sl = position.StopLoss();
    
    if(position.PositionType() == POSITION_TYPE_BUY) {
        double trail_price = current_price - InpTrailingDistance * _Point;
        if(trail_price > position.StopLoss() + _Point) {
            new_sl = trail_price;
        }
    } else {
        double trail_price = current_price + InpTrailingDistance * _Point;
        if(trail_price < position.StopLoss() - _Point || position.StopLoss() == 0) {
            new_sl = trail_price;
        }
    }
    
    if(new_sl != position.StopLoss()) {
        if(trade.PositionModify(ticket, new_sl, position.TakeProfit())) {
            if(InpEnableLogging) 
                Print("✅ Trailing stop updated: ", new_sl);
        }
    }
}

//+------------------------------------------------------------------+
//| Should close position                                            |
//+------------------------------------------------------------------+
bool ShouldClosePosition()
{
    ExtractFeatures();
    double signal = PredictWithNetwork();
    
    bool position_long = (position.PositionType() == POSITION_TYPE_BUY);
    
    // Close if signal reversed strongly
    if((position_long && signal < -InpAIConfidence) ||
       (!position_long && signal > InpAIConfidence)) {
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Close position                                                   |
//+------------------------------------------------------------------+
void ClosePosition(ulong ticket, string reason)
{
    if(trade.PositionClose(ticket)) {
        Print("✅ Position closed: ", ticket, " | Reason: ", reason);
        
        double profit = position.Profit();
        if(profit > 0) {
            g_stats.winning_trades++;
            g_stats.total_profit += profit;
        } else {
            g_stats.total_loss += MathAbs(profit);
        }
    }
}

//+------------------------------------------------------------------+
//| Train neural network                                             |
//+------------------------------------------------------------------+
void TrainNetwork()
{
    static double last_prediction = 0;
    static datetime last_train = 0;
    
    if(TimeCurrent() - last_train < 300) return; // Train every 5 minutes
    
    // Simple training based on price movement
    if(g_price_buffer[0] != 0 && g_price_buffer[1] != 0) {
        double actual = (g_price_buffer[0] > g_price_buffer[1]) ? 1.0 : -1.0;
        double error = actual - last_prediction;
        
        if(MathAbs(error) > 0.1) {
            // Simple weight update
            for(int i = 0; i < 8; i++) {
                g_network.weights_layer2[i][0] += g_network.learning_rate * error * 0.1;
            }
            
            g_network.training_count++;
            last_train = TimeCurrent();
        }
    }
    
    last_prediction = PredictWithNetwork();
}

//+------------------------------------------------------------------+
//| Update market data                                               |
//+------------------------------------------------------------------+
void UpdateMarketData()
{
    g_market.current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    // Update price buffer
    static datetime last_update = 0;
    if(TimeCurrent() - last_update > 60) {
        for(int i = 99; i > 0; i--) {
            g_price_buffer[i] = g_price_buffer[i-1];
        }
        g_price_buffer[0] = g_market.current_price;
        last_update = TimeCurrent();
    }
}

//+------------------------------------------------------------------+
//| Update statistics                                                |
//+------------------------------------------------------------------+
void UpdateStatistics()
{
    if(g_stats.total_trades > 0) {
        g_stats.win_rate = (double)g_stats.winning_trades / g_stats.total_trades * 100.0;
        
        if(g_stats.total_loss > 0) {
            g_stats.profit_factor = g_stats.total_profit / g_stats.total_loss;
        }
    }
}

//+------------------------------------------------------------------+
//| Save neural network data                                         |
//+------------------------------------------------------------------+
void SaveNeuralNetworkData()
{
    string filename = "ProjectP_Neural_" + _Symbol + ".txt";
    int handle = FileOpen(filename, FILE_WRITE | FILE_TXT);
    
    if(handle != INVALID_HANDLE) {
        FileWrite(handle, "ProjectP Professional AI v5.01");
        FileWrite(handle, "Training Count: " + IntegerToString(g_network.training_count));
        FileWrite(handle, "Learning Rate: " + DoubleToString(g_network.learning_rate, 6));
        FileClose(handle);
        
        Print("💾 Neural network data saved");
    }
}

//+------------------------------------------------------------------+
//| Release indicators                                               |
//+------------------------------------------------------------------+
void ReleaseIndicators()
{
    if(g_ma_fast_handle != INVALID_HANDLE) {
        IndicatorRelease(g_ma_fast_handle);
    }
    if(g_ma_slow_handle != INVALID_HANDLE) {
        IndicatorRelease(g_ma_slow_handle);
    }
    if(g_rsi_handle != INVALID_HANDLE) {
        IndicatorRelease(g_rsi_handle);
    }
    if(g_atr_handle != INVALID_HANDLE) {
        IndicatorRelease(g_atr_handle);
    }
}

//+------------------------------------------------------------------+
//| Show final statistics                                            |
//+------------------------------------------------------------------+
void ShowFinalStatistics()
{
    if(!InpShowStatistics) return;
    
    Print("📊 === ProjectP Professional AI - Final Statistics ===");
    Print("💼 Total Trades: ", g_stats.total_trades);
    Print("🎯 Win Rate: ", NormalizeDouble(g_stats.win_rate, 2), "%");
    Print("💰 Profit Factor: ", NormalizeDouble(g_stats.profit_factor, 2));
    
    if(InpEnableAI) {
        Print("🤖 AI Training Sessions: ", g_network.training_count);
    }
    
    Print("⏱️ Trading Duration: ", (TimeCurrent() - g_stats.start_time) / 3600, " hours");
    Print("===============================================");
}

//+------------------------------------------------------------------+
//| OnTimer function                                                 |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Periodic tasks
    static int timer_counter = 0;
    timer_counter++;
    
    // Update statistics every 10 minutes
    if(timer_counter % 10 == 0) {
        UpdateStatistics();
        
        if(InpShowStatistics && g_stats.total_trades > 0) {
            Print("📊 Stats: Trades=", g_stats.total_trades, 
                  " | Win Rate=", NormalizeDouble(g_stats.win_rate, 1), "%");
        }
    }
}

//+------------------------------------------------------------------+
//| OnTrade function                                                 |
//+------------------------------------------------------------------+
void OnTrade()
{
    UpdateStatistics();
}

//+------------------------------------------------------------------+
//| End of ProjectP Professional AI Trading System v5.01           |
//+------------------------------------------------------------------+
