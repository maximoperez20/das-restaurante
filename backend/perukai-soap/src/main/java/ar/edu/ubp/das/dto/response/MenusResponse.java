package ar.edu.ubp.das.dto.response;

import java.util.List;

import ar.edu.ubp.das.dto.PlatoDto;

public class MenusResponse {
  private String nroMenu;
  private String nomMenu;
  private List<PlatoDto> platos;

  public MenusResponse() {
  }

  public MenusResponse(String nroMenu, String nomMenu, List<PlatoDto> platos) {
    this.nroMenu = nroMenu;
    this.nomMenu = nomMenu;
    this.platos = platos;
  }

  public String getNroMenu() {
    return nroMenu;
  }

  public void setNroMenu(String nroMenu) {
    this.nroMenu = nroMenu;
  }
  
  public String getNomMenu() {
    return nomMenu;
  }

  public void setNomMenu(String nomMenu) {
    this.nomMenu = nomMenu;
  }
  
  public List<PlatoDto> getPlatos() {
    return platos;
  }

  public void setPlatos(List<PlatoDto> platos) {
    this.platos = platos;
  }

  public void add(PlatoDto plato) {
    this.platos.add(plato);
  }
  
}

