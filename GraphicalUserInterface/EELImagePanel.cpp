#include "EELImagePanel.h"

//Constructor for image panel. Perhaps, not entirely sure how this works yet
EELImagePanel::EELImagePanel(wxFrame* parent, wxString file, wxBitmapType format){
  image.LoadFile(file, format); //load file, ideally check to ensure file is present and loading was successful
  w = -1;
  h = -1;
}

//Called by system when the panel is redrawn or by a call to Refresh()/Update()
void EELImagePanel::paintEvent(wxPaintEvent& event){
  wxPaintDC dc(this); //potentially need to look at double-buffered dcs on system
  render(dc);
  return;
}


void EELImagePanel::paintNow(){
  wxClientDC dc(this);
  render(dc);
  return;
}

void EELImagePanel::OnSize(wxSizeEvent& event){
  Refresh();
  event.Skip(); //Skip the event
  return;
}

void EELImagePanel::render(wxDC& dc){
  int newWidth, newHeight;
  dc.GetSize(&newWidth, &newHeight);
  if(newWidth != w || newHeight != h){
    resized = wxBitmap(image.Scale(newWidth, newHeight));
    w = newWidth;
    h = newHeight;
    dc.DrawBitmap(resized, 0, 0, false);
  }
  else{
    dc.DrawBitmap(resized, 0, 0, false);
  }
  return;
}

