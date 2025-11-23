# Kado24 Kafka Library

Shared Kafka event schemas, producers, and consumers for event-driven communication across Kado24 microservices.

## 📦 Installation

Add this dependency to your service's `pom.xml`:

```xml
<dependency>
    <groupId>com.kado24</groupId>
    <artifactId>kafka-lib</artifactId>
    <version>1.0.0</version>
</dependency>
```

## 🔧 Build

```bash
cd backend/shared/kafka-lib
mvn clean install
```

## 📚 Components

### Event Types

All events extend `BaseEvent` and include:
- Event ID (UUID)
- Event type
- Timestamp
- Source service
- Version

**Available Events:**

1. **`OrderEvent`** - Order lifecycle events
   - ORDER_CREATED
   - ORDER_CONFIRMED
   - ORDER_CANCELLED
   - PAYMENT_COMPLETED
   - PAYMENT_FAILED

2. **`PaymentEvent`** - Payment processing events
   - PAYMENT_INITIATED
   - PAYMENT_PROCESSING
   - PAYMENT_SUCCESS
   - PAYMENT_FAILED
   - PAYMENT_REFUNDED

3. **`NotificationEvent`** - Notification delivery events
   - ORDER_CONFIRMED
   - PAYMENT_SUCCESS
   - VOUCHER_REDEEMED
   - VOUCHER_EXPIRING
   - PAYOUT_PROCESSED
   - MERCHANT_APPROVED

4. **`RedemptionEvent`** - Voucher redemption events
   - REDEMPTION_INITIATED
   - REDEMPTION_COMPLETED
   - REDEMPTION_FAILED
   - REDEMPTION_DISPUTED

5. **`AnalyticsEvent`** - Analytics and tracking events
   - VOUCHER_VIEWED
   - VOUCHER_SEARCHED
   - VOUCHER_PURCHASED
   - USER_REGISTERED
   - USER_LOGIN

6. **`AuditEvent`** - Audit trail events
   - CREATE
   - UPDATE
   - DELETE
   - LOGIN
   - LOGOUT
   - APPROVE
   - REJECT

### Configuration

**`KafkaProducerConfig`** - Producer configuration with:
- JSON serialization
- Compression (snappy)
- Idempotence enabled
- Retry logic

**`KafkaConsumerConfig`** - Consumer configuration with:
- JSON deserialization
- Error handling
- Auto offset management
- Concurrent listeners

### Event Publisher

**`EventPublisher`** - Centralized event publishing service

## 💡 Usage Examples

### Publishing Events

```java
@Service
@RequiredArgsConstructor
public class OrderService {
    
    private final EventPublisher eventPublisher;
    
    public void createOrder(Order order) {
        // Create order in database
        orderRepository.save(order);
        
        // Publish event
        OrderEvent event = OrderEvent.created(
            order.getId(),
            order.getOrderNumber(),
            order.getUserId(),
            order.getVoucherId(),
            order.getMerchantId(),
            order.getQuantity(),
            order.getTotalAmount(),
            order.getPlatformFee(),
            order.getMerchantAmount()
        );
        
        eventPublisher.publishOrderEvent(event);
    }
}
```

### Custom Event Creation

```java
// Create notification event
NotificationEvent notification = NotificationEvent.builder()
    .userId(123L)
    .notificationType("CUSTOM_NOTIFICATION")
    .title("Special Offer")
    .message("Check out our new vouchers!")
    .channels(List.of("PUSH", "EMAIL"))
    .priority("MEDIUM")
    .build();
notification.initDefaults("CUSTOM_NOTIFICATION", "marketing-service");

eventPublisher.publishNotificationEvent(notification);
```

### Consuming Events

```java
@Service
@Slf4j
public class NotificationConsumer {
    
    @KafkaListener(topics = "notification-events", groupId = "notification-consumer-group")
    public void consumeNotification(NotificationEvent event) {
        log.info("Received notification event: {} for user: {}", 
                event.getNotificationType(), event.getUserId());
        
        // Process notification
        if (event.getChannels().contains("PUSH")) {
            sendPushNotification(event);
        }
        if (event.getChannels().contains("EMAIL")) {
            sendEmail(event);
        }
        if (event.getChannels().contains("SMS")) {
            sendSMS(event);
        }
    }
}
```

### Multiple Event Types

```java
@Service
@Slf4j
public class AnalyticsConsumer {
    
    // Consume order events for analytics
    @KafkaListener(topics = "order-events", groupId = "analytics-group")
    public void consumeOrderEvent(OrderEvent event) {
        updateOrderMetrics(event);
    }
    
    // Consume redemption events for analytics
    @KafkaListener(topics = "redemption-events", groupId = "analytics-group")
    public void consumeRedemptionEvent(RedemptionEvent event) {
        updateRedemptionMetrics(event);
    }
}
```

### Error Handling

```java
@Service
@Slf4j
public class OrderConsumer {
    
    @KafkaListener(topics = "order-events", groupId = "order-consumer-group")
    public void consumeOrder(OrderEvent event) {
        try {
            processOrder(event);
        } catch (Exception e) {
            log.error("Failed to process order event: {}", event.getEventId(), e);
            // Event will be retried automatically
            throw e; // Rethrow to trigger retry
        }
    }
}
```

### Manual Acknowledgment

```java
@KafkaListener(topics = "payment-events", groupId = "payment-consumer-group")
public void consumePayment(PaymentEvent event, Acknowledgment acknowledgment) {
    try {
        processPayment(event);
        acknowledgment.acknowledge(); // Manual commit
    } catch (Exception e) {
        log.error("Failed to process payment event", e);
        // Don't acknowledge - will be redelivered
    }
}
```

## 🎯 Kafka Topics

| Topic | Partitions | Retention | Purpose |
|-------|------------|-----------|---------|
| `order-events` | 3 | 7 days | Order lifecycle |
| `payment-events` | 3 | 30 days | Payment processing |
| `notification-events` | 5 | 3 days | Notifications |
| `redemption-events` | 3 | 30 days | Voucher redemptions |
| `analytics-events` | 5 | 90 days | Analytics data |
| `audit-events` | 3 | 365 days | Audit trail |

## ⚙️ Configuration

In your service's `application.yml`:

```yaml
spring:
  kafka:
    bootstrap-servers: ${KAFKA_BOOTSTRAP_SERVERS:localhost:9092}
    consumer:
      group-id: ${KAFKA_GROUP_ID:my-service-group}
      auto-offset-reset: earliest
    producer:
      acks: 1
      retries: 3
```

## 🔐 Best Practices

1. **Use Factory Methods**
   ```java
   // Good
   OrderEvent event = OrderEvent.created(...);
   
   // Avoid
   OrderEvent event = new OrderEvent();
   event.setOrderId(...);
   // Missing eventId, timestamp initialization
   ```

2. **Always Call initDefaults()**
   ```java
   MyEvent event = MyEvent.builder()...build();
   event.initDefaults("EVENT_TYPE", "my-service");
   ```

3. **Use Meaningful Keys**
   ```java
   // Key determines which partition the event goes to
   // Use order number, user ID, etc. for better distribution
   eventPublisher.publishOrderEvent(event); // Uses orderNumber as key
   ```

4. **Handle Errors Gracefully**
   ```java
   @KafkaListener(topics = "my-topic")
   public void consume(MyEvent event) {
       try {
           process(event);
       } catch (Exception e) {
           log.error("Processing failed", e);
           // Optionally send to dead-letter queue
       }
   }
   ```

5. **Monitor Your Consumers**
   - Check consumer lag in Kafka UI
   - Monitor processing time
   - Set up alerts for failed messages

## 🧪 Testing

```java
@SpringBootTest
@EmbeddedKafka(topics = {"order-events"}, partitions = 1)
class EventPublisherTest {
    
    @Autowired
    private EventPublisher eventPublisher;
    
    @Test
    void testPublishOrderEvent() {
        OrderEvent event = OrderEvent.created(...);
        eventPublisher.publishOrderEvent(event);
        
        // Verify event was published
        assertNotNull(event.getEventId());
        assertNotNull(event.getTimestamp());
    }
}
```

## 📊 Monitoring

View Kafka topics and messages:
- **Kafka UI**: http://localhost:9000
- **Command Line**: 
  ```bash
  docker exec kado24-kafka kafka-topics --bootstrap-server localhost:9092 --list
  ```

## 🚀 Creating Topics

Topics are auto-created by Kafka, but you can create them explicitly:

```bash
docker exec kado24-kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic order-events --partitions 3 --replication-factor 1

docker exec kado24-kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic payment-events --partitions 3 --replication-factor 1

docker exec kado24-kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic notification-events --partitions 5 --replication-factor 1

docker exec kado24-kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic redemption-events --partitions 3 --replication-factor 1

docker exec kado24-kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic analytics-events --partitions 5 --replication-factor 1

docker exec kado24-kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --topic audit-events --partitions 3 --replication-factor 1
```

## 📝 Event Flow Examples

### Order Creation Flow

```
1. User creates order
   → OrderService publishes ORDER_CREATED event
   
2. NotificationService consumes ORDER_CREATED
   → Sends confirmation email/push to user
   
3. AnalyticsService consumes ORDER_CREATED
   → Updates sales metrics
   
4. AuditService consumes ORDER_CREATED
   → Logs to audit trail
```

### Payment Success Flow

```
1. Payment gateway callback received
   → PaymentService publishes PAYMENT_SUCCESS event
   
2. OrderService consumes PAYMENT_SUCCESS
   → Updates order status to CONFIRMED
   → Publishes ORDER_CONFIRMED event
   
3. WalletService consumes ORDER_CONFIRMED
   → Generates digital voucher
   → Creates QR code
   
4. NotificationService consumes ORDER_CONFIRMED
   → Sends voucher to user (email + push)
```

### Redemption Flow

```
1. Merchant scans QR code
   → RedemptionService publishes REDEMPTION_COMPLETED event
   
2. WalletService consumes REDEMPTION_COMPLETED
   → Marks voucher as USED
   
3. NotificationService consumes REDEMPTION_COMPLETED
   → Notifies consumer (receipt)
   → Notifies merchant (confirmation)
   
4. PayoutService consumes REDEMPTION_COMPLETED
   → Adds to weekly payout calculation
```

## 🎯 Integration Checklist

- [ ] Add kafka-lib dependency to pom.xml
- [ ] Configure bootstrap servers in application.yml
- [ ] Import KafkaProducerConfig and KafkaConsumerConfig
- [ ] Autowire EventPublisher in your service
- [ ] Create @KafkaListener methods for consuming
- [ ] Test event publishing and consumption
- [ ] Monitor consumer lag

## 📚 Additional Resources

- [Spring for Apache Kafka Documentation](https://spring.io/projects/spring-kafka)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kafka UI](http://localhost:9000) - View topics and messages






































