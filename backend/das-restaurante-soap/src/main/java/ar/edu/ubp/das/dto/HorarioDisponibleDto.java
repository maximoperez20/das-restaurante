package ar.edu.ubp.das.dto;

import java.sql.Time;

public class HorarioDisponibleDto {
    private Time horaDesde;
    private Time horaHasta;
    private Integer capacidadZona;
    private Integer yaReservados;
    private Integer disponibilidad;

    public Time getHoraDesde() {
        return horaDesde;
    }

    public void setHoraDesde(Time horaDesde) {
        this.horaDesde = horaDesde;
    }

    public Time getHoraHasta() {
        return horaHasta;
    }

    public void setHoraHasta(Time horaHasta) {
        this.horaHasta = horaHasta;
    }

    public Integer getCapacidadZona() {
        return capacidadZona;
    }

    public void setCapacidadZona(Integer capacidadZona) {
        this.capacidadZona = capacidadZona;
    }

    public Integer getYaReservados() {
        return yaReservados;
    }

    public void setYaReservados(Integer yaReservados) {
        this.yaReservados = yaReservados;
    }

    public Integer getDisponibilidad() {
        return disponibilidad;
    }

    public void setDisponibilidad(Integer disponibilidad) {
        this.disponibilidad = disponibilidad;
    }
}
