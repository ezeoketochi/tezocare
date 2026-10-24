import { createSlice, type PayloadAction } from "@reduxjs/toolkit";

interface UiState {
  sidebarCollapsed: boolean;
  mobileNavOpen: boolean;
}

const initialState: UiState = {
  sidebarCollapsed: false,
  mobileNavOpen: false,
};

const uiSlice = createSlice({
  name: "ui",
  initialState,
  reducers: {
    toggleSidebar(state) {
      state.sidebarCollapsed = !state.sidebarCollapsed;
    },
    setSidebarCollapsed(state, action: { payload: boolean }) {
      state.sidebarCollapsed = action.payload;
    },
    setMobileNavOpen(state, action: PayloadAction<boolean>) {
      state.mobileNavOpen = action.payload;
    },
  },
});

export const { toggleSidebar, setSidebarCollapsed, setMobileNavOpen } = uiSlice.actions;
export default uiSlice.reducer;
