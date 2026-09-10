package com.orra.Orrabackend.dto.booking;

import com.orra.Orrabackend.enums.BookingStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;


@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingResponseDTO {
    private Long bookingId;

    // Listing Info
    private Long listingId;
    private String listingTitle;
    private String listingImage;
    private BigDecimal dailyRate;

    //Owner Info
    private Long ownerId;
    private String ownerName;

    //Renter Info
    private Long renterId;
    private String renterName;

    //Booking Core Data
    private LocalDate startDateTime;
    private LocalDate endDateTime;
    private BigDecimal totalPrice;
    private BigDecimal depositAmount;

    private BookingStatus status;
    private Instant createdAt;

}
