-- Langue de l'interface (Beta 1.16) : français ou anglais. Les tables de textes (src/lang, src/tips) et les libellés
-- des réglages (src/config) sont remplis en place : les modules qui les ont déjà en main lisent aussitôt la nouvelle
-- langue. Le français d'origine est copié une seule fois, au premier changement. Les deux langues ont exactement les
-- mêmes clés (tests LANG_PARITY et TIPS_PARITY).
local C=require('src/config')
local L=require('src/lang')
local T=require('src/tips')
local english=require('src/lang_en')
local englishTips=require('src/tips_en')
local M={codes={'fr','en'},current='fr'}
local french
local function copy(source)
 if type(source)~='table' then return source end
 local out={}
 for key,value in pairs(source) do out[key]=copy(value) end
 return out
end
-- Sous-tables gardées (même identité), seules les valeurs changent.
local function fill(target,source)
 for key,value in pairs(source) do
  if type(value)=='table' and type(target[key])=='table' then fill(target[key],value) else target[key]=copy(value) end
 end
end
-- Libellés anglais des réglages : clé à part du fichier anglais, jamais recopiée dans la table des textes.
local function texts(source)
 local out={}
 for key,value in pairs(source) do if key~='labels' then out[key]=value end end
 return out
end
function M.valid(code) return code=='fr' or code=='en' end
-- Renvoie vrai si la langue a changé.
function M.set(code)
 if not M.valid(code) or code==M.current then return false end
 if not french then
  french={lang=copy(L),tips=copy(T),labels={}}
  for _,s in ipairs(C.schema) do french.labels[s.key]=s.label end
 end
 local lang,tips,labels
 if code=='fr' then lang,tips,labels=french.lang,french.tips,french.labels
 else lang,tips,labels=texts(english),englishTips,english.labels end
 fill(L,lang); fill(T,tips)
 for _,s in ipairs(C.schema) do s.label=labels[s.key] or s.label end
 M.current=code
 return true
end
return M
