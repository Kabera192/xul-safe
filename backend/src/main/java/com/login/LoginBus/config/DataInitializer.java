package com.login.LoginBus.config;

import com.login.LoginBus.accounts.domain.ConductorStatus;
import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.transport.domain.BusStatus;
import com.login.LoginBus.transport.infra.BusJpaEntity;
import com.login.LoginBus.transport.infra.BusRepository;
import com.login.LoginBus.transport.infra.BusStopJpaEntity;
import com.login.LoginBus.transport.infra.BusStopRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;

/**
 * DataInitializer creates sample data on startup if none exists.
 * Uses the new modular architecture repositories.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private BusStopRepository busStopRepository;

    @Autowired
    private ConductorRepository conductorRepository;

    @Autowired
    private BusRepository busRepository;

    @Override
    public void run(String... args) throws Exception {
        initializeBusStops();
        initializeConductors();
        initializeBuses();
    }

    private void initializeBusStops() {
        // Only add sample data if no bus stops exist
        if (busStopRepository.count() == 0) {
            List<BusStopJpaEntity> sampleBusStops = Arrays.asList(
                createBusStop("Central Bus Station", 6.5244, 3.3792,
                        "Ikeja Bus Terminal, Lagos", "Main terminal for all routes"),
                createBusStop("Victoria Island Stop", 6.4281, 3.4219,
                        "Adeola Odeku Street, VI", "Business district pickup point"),
                createBusStop("Lekki Phase 1", 6.4417, 3.4700,
                        "Admiralty Way, Lekki", "Residential area stop"),
                createBusStop("Maryland Mall", 6.5795, 3.3674,
                        "Ikorodu Road, Maryland", "Shopping district stop"),
                createBusStop("Yaba Tech Gate", 6.5167, 3.3667,
                        "Herbert Macaulay Way, Yaba", "Educational area stop"),
                createBusStop("Surulere Junction", 6.4969, 3.3581,
                        "Adeniran Ogunsanya Street", "Residential junction"),
                createBusStop("Festac Town Gate", 6.4667, 3.2833,
                        "23 Road, Festac", "Estate entrance stop"),
                createBusStop("Ajah Roundabout", 6.4667, 3.5667,
                        "Lekki-Epe Expressway, Ajah", "Expressway junction")
            );

            busStopRepository.saveAll(sampleBusStops);
            System.out.println("✓ Sample bus stops data created successfully");
        }
    }

    private BusStopJpaEntity createBusStop(String name, Double latitude, Double longitude,
                                            String address, String description) {
        BusStopJpaEntity stop = new BusStopJpaEntity();
        stop.setName(name);
        stop.setLatitude(latitude);
        stop.setLongitude(longitude);
        stop.setAddress(address);
        stop.setDescription(description);
        return stop;
    }

    private void initializeConductors() {
        // Create sample conductors if none exist
        if (conductorRepository.count() == 0) {
            ConductorJpaEntity conductor1 = new ConductorJpaEntity();
            conductor1.setFullName("Mugenzi Albert");
            conductor1.setPhoneNumber("078 1459 321");
            conductor1.setEmail("albert@schoolbus.com");
            conductor1.setStatus(ConductorStatus.ACTIVE);
            conductorRepository.save(conductor1);

            ConductorJpaEntity conductor2 = new ConductorJpaEntity();
            conductor2.setFullName("Uwase Marie");
            conductor2.setPhoneNumber("078 9876 543");
            conductor2.setEmail("marie@schoolbus.com");
            conductor2.setStatus(ConductorStatus.ACTIVE);
            conductorRepository.save(conductor2);

            ConductorJpaEntity conductor3 = new ConductorJpaEntity();
            conductor3.setFullName("Niyonzima Jean");
            conductor3.setPhoneNumber("078 5432 876");
            conductor3.setEmail("jean@schoolbus.com");
            conductor3.setStatus(ConductorStatus.ACTIVE);
            conductorRepository.save(conductor3);

            System.out.println("✅ Sample conductors created");
        }
    }

    private void initializeBuses() {
        // Create sample buses if none exist
        if (busRepository.count() == 0) {
            BusJpaEntity bus1 = new BusJpaEntity();
            bus1.setPlateNumber("RAE 183B");
            bus1.setModel("Toyota Coaster");
            bus1.setCapacity(30);
            bus1.setStatus(BusStatus.ACTIVE);
            busRepository.save(bus1);

            BusJpaEntity bus2 = new BusJpaEntity();
            bus2.setPlateNumber("RAD 456C");
            bus2.setModel("Nissan Civilian");
            bus2.setCapacity(25);
            bus2.setStatus(BusStatus.ACTIVE);
            busRepository.save(bus2);

            BusJpaEntity bus3 = new BusJpaEntity();
            bus3.setPlateNumber("RAB 789D");
            bus3.setModel("Mercedes-Benz Sprinter");
            bus3.setCapacity(20);
            bus3.setStatus(BusStatus.ACTIVE);
            busRepository.save(bus3);

            System.out.println("✅ Sample buses created");
        }
    }
}
