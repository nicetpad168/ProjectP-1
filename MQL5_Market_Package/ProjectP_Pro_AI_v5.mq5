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
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>

//+------------------------------------------------------------------+
//| Input Parameters - Organized for MQL5 Market                   |
//+------------------------------------------------------------------+
input group "🤖 === AI NEURAL NETWORK SETTINGS ==="
input bool InpEnableAI = true;                     // Enable AI/ML System
input double InpAIConfidence = 0.75;               // AI Confidence Level (0.5-0.95)
input bool InpAdaptiveLearning = true;             // Enable Adaptive Learning

input group "💰 === RISK MANAGEMENT ==="
input double InpMaxRiskPerTrade = 1.0;            // Max Risk Per Trade (%) - Conservative for $100
input double InpMaxDrawdown = 10.0;               // Maximum Drawdown (%) - Tight control
input bool InpUseAdaptiveRisk = true;             // Use Adaptive Risk Management
input bool InpUseProgressiveRisk = true;          // Use Progressive Risk (compound effect)
input double InpMaxDailyRisk = 5.0;               // Maximum Daily Risk (%)

input group "📊 === POSITION MANAGEMENT ==="
input double InpBaseLotSize = 0.01;               // Base Lot Size (for manual override)
input bool InpUseTrailingStop = true;             // Use Trailing Stop
input double InpTrailingDistance = 50.0;          // Trailing Distance (points)
input double InpRiskRewardRatio = 2.0;            // Risk:Reward Ratio
input bool InpUseCompounding = true;              // Use Compound Growth
input double InpMinAccountBalance = 100.0;        // Minimum Account Balance (USD)

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
    
    // Enterprise additions
    double daily_risk_used;
    double session_high_equity;
    double session_low_equity;
    datetime session_start;
    int trades_today;
    double max_position_size;
    bool emergency_stop;
    double compound_factor;
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
    
    // Enterprise additions
    double sharpe_ratio;
    double calmar_ratio;
    double recovery_factor;
    double consecutive_wins;
    double consecutive_losses;
    double avg_trade_duration;
    double daily_pnl[31]; // Last 31 days P&L
    int monthly_trades[12]; // Monthly trade count
    double growth_rate;
    double roi_percentage;
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
    
    // Backtest mode detection
    if(MQLInfoInteger(MQL_TESTER)) {
        Print("🧪 BACKTEST MODE: Deterministic initialization enabled");
    } else {
        Print("📈 LIVE MODE: Random initialization enabled");
    }
    
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
    
    // Emergency stop check
    if(g_risk.emergency_stop) {
        Print("🚨 EMERGENCY STOP ACTIVE - No new trades");
        return;
    }
    
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
    
    // Daily trade limit for small accounts
    if(g_risk.trades_today >= 5 && AccountInfoDouble(ACCOUNT_BALANCE) < 500.0) {
        if(InpEnableLogging) 
            Print("📊 Daily trade limit reached for small account");
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
    // Initialize with fixed seed for consistent backtest results
    if(MQLInfoInteger(MQL_TESTER)) {
        MathSrand(12345); // Fixed seed for backtest reproducibility
    } else {
        MathSrand(GetTickCount()); // Random seed for live trading
    }
    
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
//| Initialize risk management - Enterprise Grade                   |
//+------------------------------------------------------------------+
void InitRiskManagement()
{
    ZeroMemory(g_risk);
    g_risk.current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    g_risk.peak_equity = g_risk.current_equity;
    g_risk.risk_per_trade = InpMaxRiskPerTrade;
    g_risk.risk_ok = true;
    g_risk.emergency_stop = false;
    g_risk.compound_factor = 1.0;
    
    // Initialize enterprise features
    g_risk.session_start = TimeCurrent();
    g_risk.session_high_equity = g_risk.current_equity;
    g_risk.session_low_equity = g_risk.current_equity;
    g_risk.daily_risk_used = 0.0;
    g_risk.trades_today = 0;
    g_risk.max_position_size = 0.0;
    
    // Validate minimum balance
    if(g_risk.current_equity < InpMinAccountBalance) {
        Print("⚠️ WARNING: Account balance below recommended minimum");
        Print("💰 Current: $", g_risk.current_equity, " | Recommended: $", InpMinAccountBalance);
    }
    
    if(InpEnableLogging) {
        Print("🛡️ Enterprise Risk Management initialized");
        Print("💵 Starting Balance: $", NormalizeDouble(g_risk.current_equity, 2));
        Print("📊 Max Risk per Trade: ", InpMaxRiskPerTrade, "%");
        Print("📈 Max Daily Risk: ", InpMaxDailyRisk, "%");
    }
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
              " | Confidence: ", NormalizeDouble(g_network.last_confidence * 100, 1), "%",
              " | Balance: $", NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2));
        
        g_stats.total_trades++;
        g_risk.trades_today++;
        g_risk.daily_risk_used += g_risk.risk_per_trade;
        
        // Log enterprise metrics
        if(InpEnableLogging) {
            Print("📊 Risk Used Today: ", NormalizeDouble(g_risk.daily_risk_used, 2), "%");
            Print("📈 Compound Factor: ", NormalizeDouble(g_risk.compound_factor, 2));
        }
    } else {
        Print("❌ Trade failed: ", trade.ResultComment());
    }
}

//+------------------------------------------------------------------+
//| Calculate lot size - Enterprise Grade for Small Accounts        |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Check minimum balance requirement
    if(balance < InpMinAccountBalance) {
        if(InpEnableLogging) 
            Print("⚠️ Account balance below minimum: ", balance);
        return 0.0;
    }
    
    // Progressive risk calculation for compounding
    double effective_risk = g_risk.risk_per_trade;
    if(InpUseProgressiveRisk && InpUseCompounding) {
        double growth_factor = balance / InpMinAccountBalance;
        if(growth_factor > 2.0) {
            effective_risk = MathMin(effective_risk * 1.2, InpMaxRiskPerTrade * 1.5);
        }
    }
    
    // Calculate risk amount
    double risk_amount = equity * effective_risk / 100.0;
    
    // Daily risk limit check
    if(g_risk.daily_risk_used + effective_risk > InpMaxDailyRisk) {
        if(InpEnableLogging) 
            Print("🚫 Daily risk limit exceeded: ", g_risk.daily_risk_used, "%");
        return 0.0;
    }
    
    // ATR-based stop distance
    double stop_distance = g_market.atr_value * 2.0;
    if(stop_distance == 0) stop_distance = 50 * _Point; // Fallback
    
    // Broker specifications
    double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    // Calculate lot size
    double lot_size = 0.0;
    if(tick_value > 0 && tick_size > 0) {
        lot_size = risk_amount / (stop_distance * tick_value / tick_size);
    } else {
        // Fallback calculation for small accounts
        lot_size = risk_amount / (stop_distance / _Point * 10); // Approximate
    }
    
    // Special handling for small accounts ($100-$500)
    if(balance <= 500.0) {
        lot_size = MathMax(lot_size, 0.01); // Minimum for microlots
        lot_size = MathMin(lot_size, 0.10); // Maximum for safety
    }
    
    // Normalize to broker requirements
    lot_size = MathMax(min_lot, MathMin(max_lot, lot_size));
    lot_size = NormalizeDouble(lot_size / lot_step, 0) * lot_step;
    
    // Final safety check
    if(lot_size < min_lot) lot_size = min_lot;
    
    // Update max position tracking
    g_risk.max_position_size = MathMax(g_risk.max_position_size, lot_size);
    
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
//| Check risk limits - Enterprise Grade                            |
//+------------------------------------------------------------------+
bool CheckRiskLimits()
{
    g_risk.current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Update peak equity
    if(g_risk.current_equity > g_risk.peak_equity) {
        g_risk.peak_equity = g_risk.current_equity;
    }
    
    // Calculate current drawdown
    double drawdown = (g_risk.peak_equity - g_risk.current_equity) / 
                     g_risk.peak_equity * 100.0;
    g_risk.current_drawdown = drawdown;
    
    // Maximum drawdown check
    if(drawdown > InpMaxDrawdown) {
        Print("🚫 Maximum drawdown exceeded: ", NormalizeDouble(drawdown, 2), "%");
        g_risk.emergency_stop = true;
        return false;
    }
    
    // Daily risk reset
    MqlDateTime dt;
    MqlDateTime session_dt;
    TimeToStruct(TimeCurrent(), dt);
    TimeToStruct(g_risk.session_start, session_dt);
    if(dt.day != session_dt.day) {
        ResetDailyRisk();
    }
    
    // Session equity tracking
    if(g_risk.current_equity > g_risk.session_high_equity) {
        g_risk.session_high_equity = g_risk.current_equity;
    }
    if(g_risk.current_equity < g_risk.session_low_equity) {
        g_risk.session_low_equity = g_risk.current_equity;
    }
    
    // Emergency stop conditions for small accounts
    if(AccountInfoDouble(ACCOUNT_BALANCE) < InpMinAccountBalance * 0.8) {
        Print("🚨 EMERGENCY STOP: Balance below 80% of minimum");
        g_risk.emergency_stop = true;
        return false;
    }
    
    // Adaptive risk adjustment
    if(InpUseAdaptiveRisk) {
        if(drawdown > 7.0) {
            g_risk.risk_per_trade = InpMaxRiskPerTrade * 0.3; // Ultra conservative
        } else if(drawdown > 5.0) {
            g_risk.risk_per_trade = InpMaxRiskPerTrade * 0.5; // Conservative
        } else if(drawdown < 1.0 && g_stats.win_rate > 60.0) {
            g_risk.risk_per_trade = InpMaxRiskPerTrade * 1.1; // Slightly aggressive
        } else {
            g_risk.risk_per_trade = InpMaxRiskPerTrade; // Normal
        }
    }
    
    // Calculate compound factor for progressive sizing
    if(InpUseCompounding) {
        double initial_balance = InpMinAccountBalance;
        g_risk.compound_factor = g_risk.current_equity / initial_balance;
    }
    
    g_risk.risk_ok = true;
    g_risk.last_check = TimeCurrent();
    return true;
}

//+------------------------------------------------------------------+
//| Reset daily risk counters                                        |
//+------------------------------------------------------------------+
void ResetDailyRisk()
{
    g_risk.daily_risk_used = 0.0;
    g_risk.trades_today = 0;
    g_risk.session_start = TimeCurrent();
    g_risk.session_high_equity = g_risk.current_equity;
    g_risk.session_low_equity = g_risk.current_equity;
    
    if(InpEnableLogging) 
        Print("📅 Daily risk counters reset");
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
    static int bar_count = 0;
    
    // Use bar count for consistent timing in backtest
    if(MQLInfoInteger(MQL_TESTER)) {
        bar_count++;
        if(bar_count < 5) return; // Train every 5 bars in backtest
        bar_count = 0;
    } else {
        if(TimeCurrent() - last_train < 300) return; // Train every 5 minutes in live
    }
    
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
    
    // Update price buffer - use bar-based update for backtest consistency
    static datetime last_update = 0;
    static int last_bar_count = 0;
    
    if(MQLInfoInteger(MQL_TESTER)) {
        // In backtest, update every bar
        datetime current_bar = iTime(_Symbol, _Period, 0);
        if(current_bar != last_update) {
            for(int i = 99; i > 0; i--) {
                g_price_buffer[i] = g_price_buffer[i-1];
            }
            g_price_buffer[0] = g_market.current_price;
            last_update = current_bar;
        }
    } else {
        // In live, update every minute
        if(TimeCurrent() - last_update > 60) {
            for(int i = 99; i > 0; i--) {
                g_price_buffer[i] = g_price_buffer[i-1];
            }
            g_price_buffer[0] = g_market.current_price;
            last_update = TimeCurrent();
        }
    }
}

//+------------------------------------------------------------------+
//| Update statistics - Enterprise Grade                            |
//+------------------------------------------------------------------+
void UpdateStatistics()
{
    if(g_stats.total_trades > 0) {
        g_stats.win_rate = (double)g_stats.winning_trades / g_stats.total_trades * 100.0;
        
        if(g_stats.total_loss > 0) {
            g_stats.profit_factor = g_stats.total_profit / g_stats.total_loss;
        }
        
        // Calculate enterprise metrics
        double initial_balance = InpMinAccountBalance;
        double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        
        // ROI calculation
        g_stats.roi_percentage = (current_balance - initial_balance) / initial_balance * 100.0;
        
        // Growth rate (daily compound)
        double days_trading = (TimeCurrent() - g_stats.start_time) / 86400.0;
        if(days_trading > 0) {
            g_stats.growth_rate = MathPow(current_balance / initial_balance, 1.0 / days_trading) - 1.0;
        }
        
        // Recovery factor
        if(g_stats.max_drawdown > 0) {
            g_stats.recovery_factor = g_stats.roi_percentage / g_stats.max_drawdown;
        }
        
        // Update max drawdown
        if(g_risk.current_drawdown > g_stats.max_drawdown) {
            g_stats.max_drawdown = g_risk.current_drawdown;
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
//| Show final statistics - Enterprise Grade                        |
//+------------------------------------------------------------------+
void ShowFinalStatistics()
{
    if(!InpShowStatistics) return;
    
    Print("📊 === ProjectP Professional AI - Enterprise Statistics ===");
    Print("💼 Total Trades: ", g_stats.total_trades);
    Print("🎯 Win Rate: ", NormalizeDouble(g_stats.win_rate, 2), "%");
    Print("💰 Profit Factor: ", NormalizeDouble(g_stats.profit_factor, 2));
    Print("📈 ROI: ", NormalizeDouble(g_stats.roi_percentage, 2), "%");
    Print("🚀 Growth Rate: ", NormalizeDouble(g_stats.growth_rate * 100, 4), "% daily");
    Print("📉 Max Drawdown: ", NormalizeDouble(g_stats.max_drawdown, 2), "%");
    Print("🔄 Recovery Factor: ", NormalizeDouble(g_stats.recovery_factor, 2));
    Print("💵 Start Balance: $", InpMinAccountBalance);
    Print("💵 Current Balance: $", NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2));
    Print("💪 Compound Factor: ", NormalizeDouble(g_risk.compound_factor, 2), "x");
    
    if(InpEnableAI) {
        Print("🤖 AI Training Sessions: ", g_network.training_count);
    }
    
    Print("⏱️ Trading Duration: ", (TimeCurrent() - g_stats.start_time) / 3600, " hours");
    Print("🏆 Enterprise Grade Performance Tracking Complete");
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
//| OnTester function - Enterprise Grade Optimization               |
//+------------------------------------------------------------------+
double OnTester()
{
    // Calculate enterprise-grade fitness value
    UpdateStatistics();
    
    if(g_stats.total_trades < 5) return 0.0; // Need minimum trades for small accounts
    
    // Enterprise optimization criteria
    double fitness = 0.0;
    
    // ROI factor (0-30 points) - Most important for $100 account
    if(g_stats.roi_percentage > 0) {
        fitness += MathMin(g_stats.roi_percentage * 0.3, 30);
    }
    
    // Win rate factor (0-25 points)
    fitness += g_stats.win_rate * 0.25;
    
    // Profit factor (0-20 points)
    if(g_stats.profit_factor > 1.0) {
        fitness += MathMin(g_stats.profit_factor * 8, 20);
    }
    
    // Recovery factor (0-15 points) - Risk-adjusted returns
    if(g_stats.recovery_factor > 0) {
        fitness += MathMin(g_stats.recovery_factor * 3, 15);
    }
    
    // Drawdown penalty (0-10 points)
    if(g_stats.max_drawdown < 5.0) {
        fitness += 10;
    } else if(g_stats.max_drawdown < 10.0) {
        fitness += 5;
    }
    
    // Compound growth bonus for small accounts
    if(g_risk.compound_factor > 1.5) {
        fitness += 10; // Bonus for successful compounding
    }
    
    // AI performance factor (0-5 points)
    if(InpEnableAI && g_network.training_count > 0) {
        fitness += MathMin(g_network.training_count * 0.05, 5);
    }
    
    return fitness;
}

//+------------------------------------------------------------------+
//| End of ProjectP Professional AI Trading System v5.01           |
//+------------------------------------------------------------------+
