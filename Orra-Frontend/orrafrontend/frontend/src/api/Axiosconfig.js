import { supabase } from "@/lib/supabaseclient";
import axios from "axios";

// Spring Boot Axios Instance
const axiosinstance = axios.create({
  baseURL: import.meta.env.VITE_SPRINGBOOT_API_URL,
  headers: {
    "Content-Type": "application/json",
  },
  withCredentials: true
});

// axiosinstance.interceptors.request.use(
//   async (config) => {
//     const { data } = await supabase.auth.getSession();
//     const token = data?.session?.access_token;

//     if (token) {
//       // Safe header assignment across all Axios versions
//       config.headers = config.headers || {};
//       config.headers["Authorization"] = `Bearer ${token}`;
//     }

//     return config;
//   },
//   (error) => Promise.reject(error)
// );

// .NET Axios Instance
const paymentAxios = axios.create({
  baseURL: import.meta.env.VITE_DOTNET_API_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

paymentAxios.interceptors.request.use(
  async (config) => {
    const { data } = await supabase.auth.getSession();
    const token = data?.session?.access_token;

    if (token) {
      config.headers = config.headers || {};
      config.headers["Authorization"] = `Bearer ${token}`;
    }

    return config;
  },
  (error) => Promise.reject(error)
);

export { paymentAxios };
export default axiosinstance;
