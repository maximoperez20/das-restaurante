package ar.edu.ubp.das.config;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Configuración de Gson con TypeAdapters para tipos de Java 8+ (LocalDate, LocalTime).
 * 
 * Gson no puede serializar/deserializar LocalDate y LocalTime por defecto porque
 * estos tipos tienen campos privados que Gson no puede acceder mediante reflexión.
 * 
 * Esta configuración proporciona adapters personalizados que convierten estos tipos
 * a/desde strings en formato ISO (yyyy-MM-dd para LocalDate, HH:mm:ss para LocalTime).
 */
@Configuration
public class GsonConfig {

    /**
     * Formato ISO para fechas (yyyy-MM-dd)
     */
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE;
    
    /**
     * Formato ISO para horas (HH:mm:ss)
     */
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_TIME;

    /**
     * Crea un Gson configurado con TypeAdapters para LocalDate y LocalTime.
     * 
     * @return Gson configurado
     */
    @Bean
    public Gson gson() {
        return new GsonBuilder()
                .registerTypeAdapter(LocalDate.class, new LocalDateAdapter())
                .registerTypeAdapter(LocalTime.class, new LocalTimeAdapter())
                .create();
    }

    /**
     * TypeAdapter para LocalDate: serializa/deserializa como string ISO (yyyy-MM-dd)
     */
    private static class LocalDateAdapter extends TypeAdapter<LocalDate> {
        @Override
        public void write(JsonWriter out, LocalDate value) throws IOException {
            if (value == null) {
                out.nullValue();
            } else {
                out.value(value.format(DATE_FORMATTER));
            }
        }

        @Override
        public LocalDate read(JsonReader in) throws IOException {
            if (in.peek() == com.google.gson.stream.JsonToken.NULL) {
                in.nextNull();
                return null;
            }
            String dateStr = in.nextString();
            return LocalDate.parse(dateStr, DATE_FORMATTER);
        }
    }

    /**
     * TypeAdapter para LocalTime: serializa/deserializa como string ISO (HH:mm:ss)
     */
    private static class LocalTimeAdapter extends TypeAdapter<LocalTime> {
        @Override
        public void write(JsonWriter out, LocalTime value) throws IOException {
            if (value == null) {
                out.nullValue();
            } else {
                out.value(value.format(TIME_FORMATTER));
            }
        }

        @Override
        public LocalTime read(JsonReader in) throws IOException {
            if (in.peek() == com.google.gson.stream.JsonToken.NULL) {
                in.nextNull();
                return null;
            }
            String timeStr = in.nextString();
            return LocalTime.parse(timeStr, TIME_FORMATTER);
        }
    }
}
