import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";
import { clearTokens } from "@/lib/api/client";
import type { SessionPharmacy, Staff } from "@/lib/api/types";
import { fetchMe } from "@/lib/features/auth/api";

export type AuthStatus = "idle" | "hydrating" | "authenticated" | "unauthenticated";

interface AuthState {
  status: AuthStatus;
  staff: Staff | null;
  pharmacy: SessionPharmacy | null;
}

const initialState: AuthState = { status: "idle", staff: null, pharmacy: null };

export const hydrateSession = createAsyncThunk<Staff, void, { rejectValue: string }>(
  "auth/hydrate",
  async (_, { rejectWithValue }) => {
    try {
      return await fetchMe();
    } catch (error) {
      clearTokens();
      return rejectWithValue(error instanceof Error ? error.message : "Session expired");
    }
  }
);

const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    startHydration(state) {
      if (state.status === "idle") state.status = "hydrating";
    },
    setSession(state, action: { payload: { staff: Staff; pharmacy: SessionPharmacy | null } }) {
      state.status = "authenticated";
      state.staff = action.payload.staff;
      state.pharmacy = action.payload.pharmacy;
    },
    updateSessionStaff(state, action: { payload: Partial<Staff> }) {
      if (state.staff) Object.assign(state.staff, action.payload);
    },
    setPharmacy(state, action: { payload: SessionPharmacy | null }) {
      state.pharmacy = action.payload;
    },
    clearAuth(state) {
      state.status = "unauthenticated";
      state.staff = null;
      state.pharmacy = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(hydrateSession.pending, (state) => {
        state.status = "hydrating";
      })
      .addCase(hydrateSession.fulfilled, (state, action) => {
        state.status = "authenticated";
        state.staff = action.payload;
        state.pharmacy = action.payload.pharmacy
          ? action.payload.pharmacy
          : action.payload.pharmacy_id
            ? { id: action.payload.pharmacy_id, name: null }
            : null;
      })
      .addCase(hydrateSession.rejected, (state) => {
        state.status = "unauthenticated";
        state.staff = null;
        state.pharmacy = null;
      });
  },
});

export const { startHydration, setSession, updateSessionStaff, setPharmacy, clearAuth } = authSlice.actions;
export default authSlice.reducer;
