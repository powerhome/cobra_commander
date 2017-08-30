# frozen_string_literal: true

class AppHelper
  class << self
    def root
      File.expand_path(
        "./app",
        File.dirname(__FILE__)
      )
    end

    def tree # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      {
        name: "App",
        path: root,
        ancestry: Set.new,
        dependencies: [
          {
            name: "a",
            path: "#{root}/components/a",
            ancestry: Set.new(
              [
                { name: "App", path: root },
              ]
            ),
            dependencies: [
              {
                name: "b",
                path: "#{root}/components/b",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "a", path: "#{root}/components/a" },
                  ]
                ),
                dependencies: [
                  {
                    name: "g",
                    path: "#{root}/components/g",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "a", path: "#{root}/components/a" },
                        { name: "b", path: "#{root}/components/b" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "e",
                        path: "#{root}/components/e",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root },
                            { name: "a", path: "#{root}/components/a" },
                            { name: "b", path: "#{root}/components/b" },
                            { name: "g", path: "#{root}/components/g" },
                          ]
                        ),
                        dependencies: [],
                      },
                      {
                        name: "f",
                        path: "#{root}/components/f",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root },
                            { name: "a", path: "#{root}/components/a" },
                            { name: "b", path: "#{root}/components/b" },
                            { name: "g", path: "#{root}/components/g" },
                          ]
                        ),
                        dependencies: [],
                      },
                    ],
                  },
                ],
              },
              {
                name: "c",
                path: "#{root}/components/c",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "a", path: "#{root}/components/a" },
                  ]
                ),
                dependencies: [
                  {
                    name: "b",
                    path: "#{root}/components/b",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "a", path: "#{root}/components/a" },
                        { name: "c", path: "#{root}/components/c" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "g",
                        path: "#{root}/components/g",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root },
                            { name: "a", path: "#{root}/components/a" },
                            { name: "c", path: "#{root}/components/c" },
                            { name: "b", path: "#{root}/components/b" },
                          ]
                        ),
                        dependencies: [
                          {
                            name: "e",
                            path: "#{root}/components/e",
                            ancestry: Set.new(
                              [
                                { name: "App", path: root },
                                { name: "a", path: "#{root}/components/a" },
                                { name: "c", path: "#{root}/components/c" },
                                { name: "b", path: "#{root}/components/b" },
                                { name: "g", path: "#{root}/components/g" },
                              ]
                            ),
                            dependencies: [],
                          },
                          {
                            name: "f",
                            path: "#{root}/components/f",
                            ancestry: Set.new(
                              [
                                { name: "App", path: root },
                                { name: "a", path: "#{root}/components/a" },
                                { name: "c", path: "#{root}/components/c" },
                                { name: "b", path: "#{root}/components/b" },
                                { name: "g", path: "#{root}/components/g" },
                              ]
                            ),
                            dependencies: [],
                          },
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
          {
            name: "d",
            path: "#{root}/components/d",
            ancestry: Set.new(
              [
                { name: "App", path: root },
              ]
            ),
            dependencies: [
              {
                name: "b",
                path: "#{root}/components/b",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "d", path: "#{root}/components/d" },
                  ]
                ),
                dependencies: [
                  {
                    name: "g",
                    path: "#{root}/components/g",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "d", path: "#{root}/components/d" },
                        { name: "b", path: "#{root}/components/b" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "e",
                        path: "#{root}/components/e",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root },
                            { name: "d", path: "#{root}/components/d" },
                            { name: "b", path: "#{root}/components/b" },
                            { name: "g", path: "#{root}/components/g" },
                          ]
                        ),
                        dependencies: [],
                      },
                      {
                        name: "f",
                        path: "#{root}/components/f",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root },
                            { name: "d", path: "#{root}/components/d" },
                            { name: "b", path: "#{root}/components/b" },
                            { name: "g", path: "#{root}/components/g" },
                          ]
                        ),
                        dependencies: [],
                      },
                    ],
                  },
                ],
              },
              {
                name: "c",
                path: "#{root}/components/c",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "d", path: "#{root}/components/d" },
                  ]
                ),
                dependencies: [
                  {
                    name: "b",
                    path: "#{root}/components/b",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "d", path: "#{root}/components/d" },
                        { name: "c", path: "#{root}/components/c" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "g",
                        path: "#{root}/components/g",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root },
                            { name: "d", path: "#{root}/components/d" },
                            { name: "c", path: "#{root}/components/c" },
                            { name: "b", path: "#{root}/components/b" },
                          ]
                        ),
                        dependencies: [
                          {
                            name: "e",
                            path: "#{root}/components/e",
                            ancestry: Set.new(
                              [
                                { name: "App", path: root },
                                { name: "d", path: "#{root}/components/d" },
                                { name: "c", path: "#{root}/components/c" },
                                { name: "b", path: "#{root}/components/b" },
                                { name: "g", path: "#{root}/components/g" },
                              ]
                            ),
                            dependencies: [],
                          },
                          {
                            name: "f",
                            path: "#{root}/components/f",
                            ancestry: Set.new(
                              [
                                { name: "App", path: root },
                                { name: "d", path: "#{root}/components/d" },
                                { name: "c", path: "#{root}/components/c" },
                                { name: "b", path: "#{root}/components/b" },
                                { name: "g", path: "#{root}/components/g" },
                              ]
                            ),
                            dependencies: [],
                          },
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
          {
            name: "node_manifest",
            path: "#{root}/node_manifest",
            ancestry: Set.new(
              [
                { name: "App", path: root },
              ]
            ),
            dependencies: [
              {
                name: "b",
                path: "#{root}/components/b",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "node_manifest", path: "#{root}/node_manifest" },
                  ]
                ),
                dependencies: [
                  {
                    name: "g",
                    path: "#{root}/components/g",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "node_manifest", path: "#{root}/node_manifest" },
                        { name: "b", path: "#{root}/components/b" },
                      ]
                    ),
                    dependencies: [
                      {
                        name: "e",
                        path: "#{root}/components/e",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root },
                            { name: "node_manifest", path: "#{root}/node_manifest" },
                            { name: "b", path: "#{root}/components/b" },
                            { name: "g", path: "#{root}/components/g" },
                          ]
                        ),
                        dependencies: [],
                      },
                      {
                        name: "f",
                        path: "#{root}/components/f",
                        ancestry: Set.new(
                          [
                            { name: "App", path: root },
                            { name: "node_manifest", path: "#{root}/node_manifest" },
                            { name: "b", path: "#{root}/components/b" },
                            { name: "g", path: "#{root}/components/g" },
                          ]
                        ),
                        dependencies: [],
                      },
                    ],
                  },
                ],
              },
              {
                name: "e",
                path: "#{root}/components/e",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "node_manifest", path: "#{root}/node_manifest" },
                  ]
                ),
                dependencies: [],
              },
              {
                name: "f",
                path: "#{root}/components/f",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "node_manifest", path: "#{root}/node_manifest" },
                  ]
                ),
                dependencies: [],
              },
              {
                name: "g",
                path: "#{root}/components/g",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "node_manifest", path: "#{root}/node_manifest" },
                  ]
                ),
                dependencies: [
                  {
                    name: "e",
                    path: "#{root}/components/e",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "node_manifest", path: "#{root}/node_manifest" },
                        { name: "g", path: "#{root}/components/g" },
                      ]
                    ),
                    dependencies: [],
                  },
                  {
                    name: "f",
                    path: "#{root}/components/f",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "node_manifest", path: "#{root}/node_manifest" },
                        { name: "g", path: "#{root}/components/g" },
                      ]
                    ),
                    dependencies: [],
                  },
                ],
              },
            ],
          },
        ],
      }
    end
  end
end
