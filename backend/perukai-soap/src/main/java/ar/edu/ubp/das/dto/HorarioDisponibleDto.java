package ar.edu.ubp.das.dto;

import java.sql.Time;

public class HorarioDisponibleDto {
    private String codZona;
    private String nomZona;
    private Time horaDesde;
    private Time horaHasta;
    private Integer capacidadZona;
    private Boolean permiteMenores;
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

    public String getCodZona() {
        return codZona;
    }

    public void setCodZona(String codZona) {
        this.codZona = codZona;
    }

    public String getNomZona() {
        return nomZona;
    }

    public void setNomZona(String nomZona) {
        this.nomZona = nomZona;
    }

    public Boolean getPermiteMenores() {
        return permiteMenores;
    }

    public void setPermiteMenores(Boolean permiteMenores) {
        this.permiteMenores = permiteMenores;
    }
}
