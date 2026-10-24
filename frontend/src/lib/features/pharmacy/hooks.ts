"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { getErrorMessage } from "@/lib/api/errors";
import { setPharmacy } from "@/lib/redux/authSlice";
import { useAppDispatch } from "@/lib/redux/hooks";
import { getMyPharmacy, updateMyPharmacy } from "./api";
import { pharmacyKeys } from "./keys";

export function useMyPharmacy(enabled = true) {
  return useQuery({
    queryKey: pharmacyKeys.me(),
    queryFn: getMyPharmacy,
    enabled,
    staleTime: 5 * 60_000,
  });
}

export function useUpdateMyPharmacy() {
  const queryClient = useQueryClient();
  const dispatch = useAppDispatch();
  return useMutation({
    mutationFn: (payload: { name?: string; email?: string; phone?: string; address?: string }) =>
      updateMyPharmacy(payload),
    onSuccess: (pharmacy) => {
      queryClient.setQueryData(pharmacyKeys.me(), pharmacy);
      dispatch(setPharmacy({ id: pharmacy.id, name: pharmacy.name }));
      toast.success("Pharmacy updated");
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  });
}
