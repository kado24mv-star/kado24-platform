package com.kado24.mock.payment.controller;

import com.kado24.mock.payment.dto.MockPaymentRequest;
import com.kado24.mock.payment.dto.MockPaymentResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Mock payment gateway controller
 * Simulates ABA, Wing, Pi Pay, and KHQR payment gateways
 */
@Slf4j
@RestController
@RequestMapping("/api/mock/payment")
public class MockPaymentController {

    private final Map<String, MockPaymentResponse> payments = new HashMap<>();

    /**
     * Initialize payment (simulates all gateways)
     */
    @PostMapping("/init")
    public ResponseEntity<MockPaymentResponse> initPayment(@RequestBody MockPaymentRequest request) {
        log.info("Mock payment initiated: {} for amount: {}", request.getOrderId(), request.getAmount());

        String paymentId = "MOCK-" + request.getMethod().toUpperCase() + "-" + UUID.randomUUID().toString().substring(0, 8);

        MockPaymentResponse response = MockPaymentResponse.builder()
                .paymentId(paymentId)
                .orderId(request.getOrderId())
                .amount(request.getAmount())
                .paymentUrl("http://localhost:8095/mock/payment/page?id=" + paymentId)
                .qrCode("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==")
                .expiresIn(900) // 15 minutes
                .status("INITIATED")
                .build();

        payments.put(paymentId, response);

        return ResponseEntity.ok(response);
    }

    /**
     * Payment page (HTML)
     */
    @GetMapping("/page")
    public String paymentPage(@RequestParam String id) {
        MockPaymentResponse payment = payments.get(id);
        if (payment == null) {
            return "<html><body><h1>Payment not found</h1></body></html>";
        }

        return """
                <html>
                <head>
                    <title>Mock Payment Gateway</title>
                    <style>
                        body { font-family: Arial; text-align: center; padding: 50px; }
                        .container { max-width: 400px; margin: 0 auto; }
                        h1 { color: #333; }
                        .amount { font-size: 48px; color: #27ae60; margin: 20px 0; }
                        button { padding: 15px 30px; margin: 10px; font-size: 16px; cursor: pointer; border: none; border-radius: 5px; }
                        .success { background: #27ae60; color: white; }
                        .fail { background: #e74c3c; color: white; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h1>🏦 Mock Payment Gateway</h1>
                        <p>Payment ID: %s</p>
                        <div class="amount">$%.2f</div>
                        <p>Order: %s</p>
                        <button class="success" onclick="processPayment(true)">✓ Pay Now (Success)</button>
                        <button class="fail" onclick="processPayment(false)">✗ Payment Failed</button>
                    </div>
                    <script>
                        function processPayment(success) {
                            fetch('/api/mock/payment/process?id=%s&success=' + success, {method: 'POST'})
                                .then(() => {
                                    alert(success ? 'Payment successful!' : 'Payment failed!');
                                    window.close();
                                });
                        }
                    </script>
                </body>
                </html>
                """.formatted(id, payment.getAmount(), payment.getOrderId(), id);
    }

    /**
     * Process payment (simulate callback)
     */
    @PostMapping("/process")
    public ResponseEntity<Map<String, String>> processPayment(
            @RequestParam String id,
            @RequestParam boolean success) {

        log.info("Processing mock payment: {} - Success: {}", id, success);

        MockPaymentResponse payment = payments.get(id);
        if (payment == null) {
            return ResponseEntity.notFound().build();
        }

        payment.setStatus(success ? "COMPLETED" : "FAILED");

        // In real scenario, this would trigger callback to payment-service
        // POST http://localhost:8085/api/v1/payments/callback

        Map<String, String> result = new HashMap<>();
        result.put("paymentId", id);
        result.put("status", payment.getStatus());
        result.put("message", success ? "Payment successful" : "Payment failed");

        return ResponseEntity.ok(result);
    }

    /**
     * Check payment status
     */
    @GetMapping("/status/{paymentId}")
    public ResponseEntity<MockPaymentResponse> getPaymentStatus(@PathVariable String paymentId) {
        MockPaymentResponse payment = payments.get(paymentId);
        if (payment == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(payment);
    }
}



















