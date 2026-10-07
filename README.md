# ORRA – Peer-to-Peer Electronics Rental Platform

ORRA is a full-stack peer-to-peer electronics rental marketplace that enables users to **list, discover, book, and rent electronic products** such as cameras, drones, appliances, and other electronic devices.

The platform handles the complete rental lifecycle, including product listings, booking management, payment processing, authentication, asynchronous event processing, and user notifications.

---

## Features

- User authentication and authorization
- Create and manage electronic product listings
- Browse available products
- Book products for a rental period
- Owner-controlled booking approval
- Payment processing through a dedicated .NET service
- Asynchronous payment event processing using RabbitMQ
- Booking lifecycle management
- Product availability management
- Wishlist functionality
- Product reviews and ratings
- User notifications
- Prevention of owners booking their own products

---

## Tech Stack

### Frontend

- React.js
- Redux Toolkit
- Tailwind CSS
- shadcn/ui
- Axios

### Backend

- Java 17
- Spring Boot
- Spring Security
- Spring Data JPA
- Hibernate
- REST APIs

### Payment Service

- ASP.NET Core
- C#

### Database

- PostgreSQL

### Authentication

- Supabase Authentication
- JWT-based authentication

### Messaging

- RabbitMQ

### Infrastructure & Tools

- Docker
- Maven
- Git
- GitHub

---

## System Architecture

ORRA uses a service-oriented architecture where the core application and rental business logic are handled by the Spring Boot backend, while payment-related processing is handled by a separate .NET service.

```mermaid
flowchart TD

    User[User] --> Frontend[React Frontend]

    Frontend -->|REST APIs| Spring[Spring Boot Backend]

    Frontend -->|Authentication| Supabase[Supabase Auth]

    Spring -->|Validate User| Supabase

    Spring --> PostgreSQL[(PostgreSQL)]

    Frontend -->|Payment Request| PaymentService[.NET Payment Service]

    PaymentService --> Gateway[Payment Gateway]

    Gateway -->|Webhook| PaymentService

    PaymentService -->|payment.success| RabbitMQ[RabbitMQ]

    RabbitMQ -->|Consume Event| Spring

    Spring -->|Update Application State| PostgreSQL
```

### Architecture Overview

- **React** provides the user interface and communicates with backend services using REST APIs.
- **Spring Boot** handles listings, bookings, users, reviews, wishlists, notifications, and the core rental business logic.
- **PostgreSQL** stores the application's relational data.
- **Supabase Authentication** manages user authentication and JWT-based sessions.
- **ASP.NET Core** handles payment-related processing and payment webhook verification.
- **RabbitMQ** enables asynchronous communication between the payment service and Spring Boot backend.

---

## Booking & Payment Flow

A booking moves through multiple stages before a rental becomes active.

```mermaid
flowchart TD

    A[User selects a product] --> B[Create Booking]

    B --> C[PENDING]

    C -->|Owner Accepts| D[ACCEPTED]

    D --> E[User Completes Payment]

    E --> F[Payment Gateway]

    F -->|Webhook| G[.NET Payment Service]

    G -->|Verify Payment| H[RabbitMQ]

    H -->|payment.success Event| I[Spring Boot Listener]

    I --> J[Booking → ACTIVE]

    I --> K[Listing → Unavailable]

    I --> L[Create Notification]
```

### Flow Explanation

1. A renter selects an available product and creates a booking.
2. The booking is initially created with `PENDING` status.
3. The product owner reviews the booking request.
4. If accepted, the booking moves to `ACCEPTED`.
5. The renter completes the payment.
6. The payment gateway sends a webhook to the .NET payment service.
7. The .NET service verifies the payment.
8. After successful verification, a `payment.success` event is published through RabbitMQ.
9. The Spring Boot backend consumes the event.
10. The booking status changes to `ACTIVE`.
11. The corresponding product becomes unavailable for other renters.
12. A notification is created for the relevant user.

---

## Booking Lifecycle

The booking lifecycle ensures that every rental moves through controlled states.

```mermaid
stateDiagram-v2

    [*] --> PENDING

    PENDING --> ACCEPTED : Owner accepts
    PENDING --> CANCELLED : Booking cancelled

    ACCEPTED --> ACTIVE : Payment successful
    ACCEPTED --> CANCELLED : Cancelled / payment not completed

    ACTIVE --> COMPLETED : Rental completed

    COMPLETED --> [*]
    CANCELLED --> [*]
```

### Booking States

| Status | Description |
|---|---|
| `PENDING` | Booking request has been created and is waiting for owner approval |
| `ACCEPTED` | Owner has approved the booking and payment is pending |
| `ACTIVE` | Payment has been completed and the rental is active |
| `COMPLETED` | Rental period has finished |
| `CANCELLED` | Booking has been cancelled |

---

## Business Rules

ORRA implements business rules to maintain consistency throughout the rental lifecycle.

- Product owners cannot book their own products.
- Only active and available products can be booked.
- A new booking starts with `PENDING` status.
- Only the product owner can accept the corresponding booking request.
- An accepted booking must be paid within the allowed payment window.
- Successful payment changes the booking status to `ACTIVE`.
- A product becomes unavailable after successful payment.
- An unavailable product cannot be booked by another renter.
- After the rental is completed, the product becomes available again.
- Payment events are processed asynchronously through RabbitMQ.

---

## Database Design

ORRA uses **PostgreSQL** as its primary relational database.

The database is designed around users, product listings, bookings, transactions, notifications, wishlists, product images, and user roles.

### Entity Relationship Diagram

<p align="center">
  <img
    src="docs/images/er-diagram.png"
    alt="ORRA Entity Relationship Diagram"
    width="100%"
  >
</p>

### Core Relationships

- A **User** can create multiple **Listings**.
- A **User** can have multiple **Roles**.
- A **User** can add multiple products to their **Wishlist**.
- A **Listing** belongs to an owner.
- A **Listing** can contain multiple **Listing Images**.
- A **Listing** can have multiple **Bookings**.
- A **Booking** references a renter and a product listing.
- A **Booking** can have multiple **Transactions**.
- A **Booking** can generate multiple **Notifications**.

### Major Tables

| Table | Purpose |
|---|---|
| `users` | Stores user profile and account information |
| `user_roles` | Stores roles assigned to users |
| `listings` | Stores electronic products listed for rent |
| `listing_images` | Stores images associated with product listings |
| `bookings` | Stores rental booking information and lifecycle status |
| `transactions` | Stores payment transaction information |
| `wishlist` | Stores products saved by users |
| `notifications` | Stores booking and payment-related notifications |

> The ER diagram is maintained alongside the project so that the database model can evolve with the application.

---

## Backend Architecture

The Spring Boot backend follows a layered architecture to separate API handling, business logic, and database access.

```text
Client Request
      │
      ▼
Controller
      │
      ▼
Service
      │
      ▼
Repository
      │
      ▼
Spring Data JPA / Hibernate
      │
      ▼
PostgreSQL
```

### Controller Layer

Handles incoming HTTP requests, validates request data, and returns API responses.

### Service Layer

Contains the application's business logic, including booking rules, authorization checks, product availability, and status transitions.

### Repository Layer

Provides database access using Spring Data JPA repositories.

### Entity Layer

Maps Java objects to relational database tables using JPA and Hibernate.

### DTO Layer

Transfers required information between the backend and client without exposing persistence entities directly.

---

## Core Modules

### Product Listings

Users can create and manage electronic products available for rent.

Listings contain information such as:

- Product name
- Category
- Brand
- Model
- Description
- Daily rental rate
- Security deposit
- Location
- Availability status
- Product images

---

### Booking Management

The booking module manages the rental lifecycle.

It is responsible for:

- Creating booking requests
- Owner approval
- Booking status transitions
- Rental start and end dates
- Product availability
- Booking cancellation
- Booking completion

---

### Payment Processing

Payment processing is separated from the main Spring Boot backend.

The .NET payment service is responsible for:

- Handling payment-related operations
- Receiving payment gateway webhooks
- Verifying payment events
- Publishing successful payment events

RabbitMQ is used to asynchronously communicate successful payment events to the Spring Boot backend.

---

### Notifications

Notifications are generated for important booking and payment events so users can track changes related to their rental requests.

---

### Wishlist

Users can save products to their wishlist for later viewing.

---

## REST API Overview

The Spring Boot backend exposes REST APIs for the application's core functionality.

Major API groups include:

```text
Authentication APIs
User APIs
Listing APIs
Booking APIs
Wishlist APIs
Notification APIs
```

The React frontend communicates with these APIs using Axios.

Detailed API documentation can be added using Swagger / OpenAPI.

---

## Authentication Flow

ORRA uses Supabase Authentication with JWT-based sessions.

```mermaid
sequenceDiagram

    participant User
    participant React
    participant Supabase
    participant SpringBoot

    User->>React: Login
    React->>Supabase: Authenticate

    Supabase-->>React: JWT Access Token

    React->>SpringBoot: API Request + Bearer Token

    SpringBoot->>SpringBoot: Validate Token

    SpringBoot-->>React: Protected Resource
```

The frontend attaches the access token to protected API requests:

```text
Authorization: Bearer <access-token>
```

Authorization rules are enforced by the backend rather than relying only on frontend restrictions.

---

## Project Structure

```text
Orra/
│
├── README.md
│
│
├── docs/
│   ├── images/
│   │   └── er-diagram.png
│   │
│   └── diagrams/
│       └── er-diagram.mermaid
│
├── Orra-Backend-SpringBoot/
│   └── Orrabackend/
│       └── Spring Boot backend
│
├── Orra-Frontend/
│   └── React frontend
│
├── Orra-backend-dotnet/
│   └── .NET payment service
│
└── Orra-databases/
    └── orra_database/
        └── PostgreSQL database scripts
```

---

## Running the Project Locally

### Prerequisites

Install the following before running the project:

- Java 17+
- Maven
- Node.js
- npm
- .NET SDK
- PostgreSQL
- RabbitMQ
- Git

Docker can optionally be used for supporting infrastructure.

---

### Clone the Repository

```bash
git clone https://github.com/atul94063/Orra.git
cd Orra
```

---

### Start the Spring Boot Backend

```bash
cd Orra-Backend-SpringBoot/Orrabackend
mvn spring-boot:run
```

---

### Start the React Frontend

```bash
cd Orra-Frontend
npm install
npm run dev
```

---

### Start the .NET Payment Service

Navigate to the .NET service directory and run:

```bash
dotnet restore
dotnet run
```

---

### Configure PostgreSQL

Create the PostgreSQL database and configure the required database connection properties before starting the backend.

Sensitive information such as database passwords, authentication secrets, and payment credentials should be supplied through environment variables and should not be committed to the repository.

---

## Security

The application follows several security practices:

- JWT-based authentication
- Spring Security for protected backend endpoints
- Backend authorization checks
- Environment variables for sensitive configuration
- Payment webhook verification
- Validation of booking ownership and permissions
- DTOs to avoid exposing persistence entities directly

---

## Future Improvements

The following improvements are planned as the project evolves:

- Add automated unit and integration testing
- Add Swagger / OpenAPI documentation
- Add Docker Compose for running the complete application
- Add GitHub Actions CI/CD pipeline
- Improve database indexing for frequently queried columns
- Add centralized exception handling
- Improve application logging and monitoring
- Add frontend and backend deployment
- Add application screenshots and demo
- Expand technical documentation as the project grows

---

## Author

**Atul Golchha**

Full-Stack Developer focused on **Java, Spring Boot, React, REST APIs, PostgreSQL, and backend development**.
