// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ble/qlv2/protocol_handler.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:flutter/material.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

enum _Qlv2Diagnostic { echo, benchmark }

class Qlv2DiagnosticsPage extends StatefulWidget {
  const Qlv2DiagnosticsPage({super.key});

  @override
  State<Qlv2DiagnosticsPage> createState() => _Qlv2DiagnosticsPageState();
}

class _Qlv2DiagnosticsPageState extends State<Qlv2DiagnosticsPage> {
  static const _benchmarkSizesKiB = [
    16,
    32,
    64,
    128,
    256,
    512,
    1024,
    2048,
    3072,
    4096,
    8192,
    16384,
  ];
  static const _receiveWindowsKiB = [64, 128, 256, 512, 1024];

  final _echoController = TextEditingController(text: 'Hello from Envoy');
  final _logs = <String>[];
  StreamSubscription<List<QLConnection>>? _connectionsSubscription;
  StreamSubscription<bool>? _activeSubscription;
  List<QLConnection> _connections = const [];
  String? _selectedDeviceId;
  _Qlv2Diagnostic _selectedDiagnostic = _Qlv2Diagnostic.echo;
  qlv2.PassportEchoResult? _echoResult;
  qlv2.PassportBenchmarkResult? _benchmarkResult;
  int _benchmarkSizeKiB = 3072;
  int _receiveWindowKiB = 256;
  bool _active = false;
  bool _busy = false;
  String? _error;

  QLConnection? get _connection {
    for (final connection in _connections) {
      if (connection.deviceId == _selectedDeviceId) return connection;
    }
    return null;
  }

  QLV2ProtocolHandler? get _handler => _connection?.v2Handler;

  @override
  void initState() {
    super.initState();
    _setConnections(BluetoothChannel().deviceChannels, rebuild: false);
    _connectionsSubscription =
        BluetoothChannel().deviceChannelsStream.listen(_setConnections);
  }

  void _setConnections(
    List<QLConnection> connections, {
    bool rebuild = true,
  }) {
    if (rebuild && !mounted) return;
    final qlv2Connections = connections
        .where((connection) => connection.v2Handler != null)
        .toList();
    final selectedStillExists = qlv2Connections.any(
      (connection) => connection.deviceId == _selectedDeviceId,
    );
    void update() {
      _connections = qlv2Connections;
      if (!selectedStillExists) {
        _selectedDeviceId =
            qlv2Connections.isEmpty ? null : qlv2Connections.first.deviceId;
      }
    }

    if (rebuild && mounted) {
      setState(update);
    } else {
      update();
    }
    _listenToSelectedSession(rebuild: rebuild);
  }

  void _listenToSelectedSession({bool rebuild = true}) {
    if (rebuild && !mounted) return;
    unawaited(_activeSubscription?.cancel());
    final handler = _handler;
    final active = handler?.isActive ?? false;
    if (rebuild && mounted) {
      setState(() => _active = active);
    } else {
      _active = active;
    }
    _activeSubscription = handler?.activeStream.listen((active) {
      if (mounted) setState(() => _active = active);
    });
  }

  void _selectDevice(String? deviceId) {
    setState(() {
      _selectedDeviceId = deviceId;
      _echoResult = null;
      _benchmarkResult = null;
      _error = null;
    });
    _listenToSelectedSession();
  }

  void _addLog(String message) {
    if (!mounted) return;
    setState(() {
      _logs.insert(0, message);
      if (_logs.length > 30) _logs.removeLast();
    });
  }

  Future<void> _runEcho() async {
    final handler = _handler;
    if (handler == null || !_active) return;
    final message = _echoController.text.isEmpty
        ? 'Hello from Envoy'
        : _echoController.text;
    setState(() {
      _busy = true;
      _error = null;
      _echoResult = null;
    });
    try {
      final result = await handler.runPassportEcho(message);
      if (!mounted || !identical(handler, _handler)) return;
      setState(() => _echoResult = result);
      _addLog('Echo completed in ${result.milliseconds.toStringAsFixed(1)} ms');
    } catch (error) {
      if (!mounted || !identical(handler, _handler)) return;
      setState(() => _error = 'Echo failed: $error');
      _addLog('Echo failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runBenchmark() async {
    final handler = _handler;
    if (handler == null || !_active) return;
    final bytes = _benchmarkSizeKiB * 1024;
    final receiveWindow = _receiveWindowKiB * 1024;
    setState(() {
      _busy = true;
      _error = null;
      _benchmarkResult = null;
    });
    _addLog('Benchmark started: $_benchmarkSizeKiB KiB');
    try {
      final result = await handler.runPassportBenchmark(
        bytes: bytes,
        receiveWindow: receiveWindow,
      );
      if (!mounted || !identical(handler, _handler)) return;
      setState(() => _benchmarkResult = result);
      _addLog(
        'Benchmark verified: ${result.mibPerSecond.toStringAsFixed(2)} MiB/s',
      );
    } catch (error) {
      if (!mounted || !identical(handler, _handler)) return;
      setState(() => _error = 'Benchmark failed: $error');
      _addLog('Benchmark failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    unawaited(_connectionsSubscription?.cancel());
    unawaited(_activeSubscription?.cancel());
    _echoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const surfaceColor = Colors.black;
    const subtitleColor = Color(0xFFB9BBC1);
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: surfaceColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QLv2 diagnostics'),
          actions: [
            Icon(
              Icons.circle,
              size: 12,
              color: _active ? Colors.greenAccent : Colors.redAccent,
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_connections.isEmpty)
                const _InfoCard(
                  title: 'No QLv2 Passport session',
                  body:
                      'Pair or reconnect a QLv2 Passport, then reopen this page.',
                )
              else ...[
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedDeviceId),
                  initialValue: _selectedDeviceId,
                  decoration: const InputDecoration(
                    labelText: 'Passport',
                    border: OutlineInputBorder(),
                  ),
                  items: _connections
                      .map(
                        (connection) => DropdownMenuItem(
                          value: connection.deviceId,
                          child: Text(
                            connection.getDevice()?.name ?? connection.deviceId,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _busy ? null : _selectDevice,
                ),
                const SizedBox(height: 8),
                Text(
                  _active
                      ? 'QLv2 peer connected and permissions granted'
                      : 'Waiting for an active QLv2 session',
                  style: const TextStyle(color: subtitleColor),
                ),
                const SizedBox(height: 24),
                SegmentedButton<_Qlv2Diagnostic>(
                  segments: const [
                    ButtonSegment(
                      value: _Qlv2Diagnostic.echo,
                      label: Text('Echo'),
                    ),
                    ButtonSegment(
                      value: _Qlv2Diagnostic.benchmark,
                      label: Text('Benchmark'),
                    ),
                  ],
                  selected: {_selectedDiagnostic},
                  onSelectionChanged: _busy
                      ? null
                      : (selection) => setState(
                            () => _selectedDiagnostic = selection.single,
                          ),
                ),
                const SizedBox(height: 24),
                if (_selectedDiagnostic == _Qlv2Diagnostic.echo)
                  _buildEcho()
                else
                  _buildBenchmark(),
                if (_busy) ...[
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(),
                ],
                if (_error case final error?) ...[
                  const SizedBox(height: 16),
                  Text(error, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 28),
                Text('Activity',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_logs.isEmpty)
                  const Text(
                    'No diagnostics run yet.',
                    style: TextStyle(color: subtitleColor),
                  )
                else
                  ..._logs.map(
                    (log) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(log),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEcho() {
    final result = _echoResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _echoController,
          enabled: !_busy,
          maxLength: 65536,
          decoration: const InputDecoration(
            labelText: 'Echo payload',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _active && !_busy ? _runEcho : null,
          child: const Text('Send Echo'),
        ),
        if (result != null) ...[
          const SizedBox(height: 16),
          Text('Reply: ${result.message}'),
          Text('${result.milliseconds.toStringAsFixed(1)} ms'),
        ],
      ],
    );
  }

  Widget _buildBenchmark() {
    final result = _benchmarkResult;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<int>(
          initialValue: _benchmarkSizeKiB,
          decoration: const InputDecoration(
            labelText: 'Download size',
            border: OutlineInputBorder(),
          ),
          items: _benchmarkSizesKiB
              .map(
                (size) => DropdownMenuItem(
                  value: size,
                  child: Text(_formatKiB(size)),
                ),
              )
              .toList(),
          onChanged: _busy
              ? null
              : (size) => setState(() => _benchmarkSizeKiB = size!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          initialValue: _receiveWindowKiB,
          decoration: const InputDecoration(
            labelText: 'Receive window',
            border: OutlineInputBorder(),
          ),
          items: _receiveWindowsKiB
              .map(
                (size) => DropdownMenuItem(
                  value: size,
                  child: Text(_formatKiB(size)),
                ),
              )
              .toList(),
          onChanged: _busy
              ? null
              : (size) => setState(() => _receiveWindowKiB = size!),
        ),
        const SizedBox(height: 12),
        const Text(
          'Verifies byte count and SHA-256. Timing starts after Passport sends the response header.',
          style: TextStyle(color: Color(0xFFB9BBC1)),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _active && !_busy ? _runBenchmark : null,
          child: const Text('Test Throughput'),
        ),
        if (result != null) ...[
          const SizedBox(height: 16),
          Text(
            '${result.bytes} bytes verified in ${result.seconds.toStringAsFixed(2)} s',
          ),
          Text(
            '${result.mibPerSecond.toStringAsFixed(2)} MiB/s '
            '(${(result.mibPerSecond * 8.388608).toStringAsFixed(2)} Mbit/s)',
          ),
        ],
      ],
    );
  }

  static String _formatKiB(int size) {
    return size >= 1024 ? '${size ~/ 1024} MiB' : '$size KiB';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
