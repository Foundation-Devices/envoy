// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::collections::HashMap;
use std::error::Error;
use std::path::PathBuf;

use bdk_wallet::KeychainKind;
use sled::{IVec, Tree};

#[allow(dead_code)]
pub(crate) enum MapKey {
    LastIndex(KeychainKind),
    SyncTime,
}

impl MapKey {
    fn as_prefix(&self) -> Vec<u8> {
        match self {
            MapKey::LastIndex(st) => [b"c", st.as_ref()].concat(),
            MapKey::SyncTime => b"l".to_vec(),
        }
    }
    fn serialize_content(&self) -> Vec<u8> {
        vec![]
    }

    pub fn as_map_key(&self) -> Vec<u8> {
        let mut v = self.as_prefix();
        v.extend_from_slice(&self.serialize_content());
        v
    }
}

fn ivec_to_u32(b: IVec) -> Result<u32, Box<dyn Error>> {
    let array: [u8; 4] = b.as_ref().try_into().map_err(|_| "Invalid U32 Bytes")?;
    let val = u32::from_be_bytes(array);
    Ok(val)
}

fn get_last_index(db: &Tree, keychain: KeychainKind) -> Result<Option<u32>, Box<dyn Error>> {
    let key = MapKey::LastIndex(keychain).as_map_key();
    db.get(key)?.map(ivec_to_u32).transpose()
}

pub fn get_last_used_index(path: &PathBuf, tree_name: String) -> HashMap<KeychainKind, u32> {
    let db = sled::open(path).unwrap();
    let tree = db.open_tree(tree_name.clone()).unwrap();

    let external = get_last_index(&tree, KeychainKind::External)
        .unwrap()
        .unwrap_or(0);
    let internal = get_last_index(&tree, KeychainKind::Internal)
        .unwrap()
        .unwrap_or(0);
    let mut key_index_map = HashMap::new();

    key_index_map.insert(KeychainKind::External, external);
    key_index_map.insert(KeychainKind::Internal, internal);
    key_index_map
}

#[cfg(test)]
mod tests {
    use std::error::Error;
    use std::fs;
    use std::path::Path;

    use sled::Db;

    use crate::api::migration::{get_last_index, KeychainKind};

    fn list_db_contents(db: &Db) -> Result<(), Box<dyn Error>> {
        for item in db.iter() {
            let (key, value) = item?;
            let key_str = std::str::from_utf8(&key)?;
            let value_str = std::str::from_utf8(&value)?;
            println!("Key: {}, Value: {}", key_str, value_str);
        }
        Ok(())
    }

    #[test]
    fn migration_test() {
        let root = Path::new("./wallets");

        if root.is_dir() {
            for entry in fs::read_dir(root).unwrap() {
                let entry = entry.unwrap();
                let path = entry.path();

                if path.is_dir() {
                    println!("Path: {:?}", path);
                    let db = sled::open(path.clone()).unwrap();

                    for (tn, tree_name) in db.tree_names().into_iter().enumerate() {
                        let tree = db.open_tree(&tree_name).unwrap();
                        // println!("Tree name: {},is tree empty ? : {}\n", std::str::from_utf8(&tree_name).unwrap(), tree.is_empty());
                        // tree.iter().for_each(|item| {
                        //     let (key, value) = item.unwrap();
                        //     println!("Key: Value: {:?}", key);
                        // });

                        // println!("\n");
                    }
                    let tree = db
                        .open_tree(format!("{}", path.file_name().unwrap().to_str().unwrap()))
                        .unwrap();

                    tree.iter().keys().for_each(|key| {
                        // println!("Key: {:?}", key);
                    });
                    let external = get_last_index(&tree, KeychainKind::External).unwrap();
                    let internal = get_last_index(&tree, KeychainKind::Internal).unwrap();

                    println!("last sync External: {:?}", external);
                    println!("last sync Internal: {:?}", internal);
                }
            }
        }
    }
}
