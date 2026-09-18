# Diagrams

The Mermaid blocks in `README.md` and `docs/00-architecture.md` render natively on
GitHub, so rendered images here are optional polish rather than a requirement.

If you add them, suggested names — referenced nowhere yet, so adding them requires
adding the image link too:

| File | Content |
|---|---|
| `topology.png` | Physical and logical layout: DC, network segment, sync path to Entra |
| `identity-flow.png` | User → on-prem AD → sync → Entra → cloud app token issuance |
| `ou-structure.png` | The OU tree as a visual hierarchy |

Export at a width of at least 1200px so text stays legible when GitHub scales the
image down.
