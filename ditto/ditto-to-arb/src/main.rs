// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

extern crate core;

use std::path::Path;
use std::fs::read_to_string;
use serde_json::{
    json,
    Map,
    Value,
    Value::Object,
};

fn main() {
    let mut intl_map = Map::new();

    // Prepend 'component_' to keys
    let components: Value = serde_json::from_str(&read_to_string(
        Path::new("../ditto-component-library__base.json")).unwrap()).unwrap();
    for pair in components.as_object().unwrap() {
        intl_map.insert("component_".to_owned() + &pair.0.clone(), pair.1.clone());
    }

    // Append '_after_onboarding' to keys
    let envoy_after_onboarding: Value = serde_json::from_str(&read_to_string(
        Path::new("../Envoy + PP Clean Start__after-onboarding.json")).unwrap()).unwrap();
    for pair in envoy_after_onboarding.as_object().unwrap() {
        intl_map.insert(pair.0.clone() + &"_after_onboarding".to_owned(), pair.1.clone());
    }

    let mut envoy_base: Value = serde_json::from_str(&read_to_string(
        Path::new("../Envoy__base.json")).unwrap()).unwrap();

    intl_map.append(envoy_base.as_object_mut().unwrap());

    let mut envoy_pp_base: Value = serde_json::from_str(&read_to_string(
        Path::new("../Envoy + PP Clean Start__base.json")).unwrap()).unwrap();

    intl_map.append(envoy_pp_base.as_object_mut().unwrap());

    // Ditto variables need an additional '@' k/v pair
    let mut variables_to_add = Map::new();

    for pair in &intl_map {
        let value = pair.1.as_str().unwrap();

        // Skip over {{links}}, Flutter knows to interpret these
        if value.contains("{{") {
            continue;
        }

        if value.contains("{") {
            let start_bytes = value.find("{").unwrap() + 1;
            let end_bytes = value.find("}").unwrap();
            let variable = &value[start_bytes..end_bytes];

            variables_to_add.insert("@".to_owned() + &pair.0.clone(),
                                    json!({variable: {"type": "String"}}));
        }
    }

    intl_map.append(&mut variables_to_add);

    let pretty_json = serde_json::to_string_pretty(&Object(intl_map)).unwrap();
    println!("{}", pretty_json.replace("\\\\n", "\\n"));
}
