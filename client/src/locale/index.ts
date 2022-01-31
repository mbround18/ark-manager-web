import { register, locale as l, init, _ } from "svelte-i18n";
import en from "./en.json";

const locales = {
  en: () => import("./en.json"),
  fr: () => import("./fr.json"),
};

Object.entries(locales).forEach(([locale, loader]) => register(locale, loader));

// en, en-US and pt are not available yet

init({
  fallbackLocale: "en",
  initialLocale: "en",
});

export function setupLocale(locale: keyof typeof locales = "en") {
  l.set(locale);
}

export type LocaleKeys = keyof typeof en;
export type LocaleFunction = (id: LocaleKeys, data?: any) => string;

// @ts-ignore
export const text: LocaleFunction = _;
